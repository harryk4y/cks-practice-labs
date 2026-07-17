###############################################################################
# Data Sources
###############################################################################

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "current" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

###############################################################################
# VPC
###############################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]

  enable_nat_gateway   = true
  single_nat_gateway   = true # Cost optimization: single NAT gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/${var.cluster_name}"    = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = 1
    "kubernetes.io/cluster/${var.cluster_name}"    = "owned"
  }

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

###############################################################################
# EKS Cluster
###############################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Cluster access
  enable_cluster_creator_admin_permissions = true

  # Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    # App node group: runs the UI + backend (spot, cost-effective)
    app = {
      name = "app-spot"

      instance_types = var.spot_instance_types
      capacity_type  = "SPOT"

      min_size     = var.min_nodes
      max_size     = var.max_nodes
      desired_size = var.min_nodes

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      labels = {
        role = "app"
        tier = "frontend"
      }

      taints = []
    }

    # Workspace node group: runs lab workspace pods (spot, scales to 0)
    workspace = {
      name = "workspace-spot"

      instance_types = var.workspace_instance_types
      capacity_type  = "SPOT"

      min_size     = var.workspace_min_nodes
      max_size     = var.workspace_max_nodes
      desired_size = var.workspace_min_nodes

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      labels = {
        role = "workspace"
        tier = "lab-environment"
      }

      taints = [
        {
          key    = "workspace"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  tags = {
    Name = var.cluster_name
  }
}
