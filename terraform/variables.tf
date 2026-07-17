variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cks-practice-labs"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.32"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "domain_name" {
  description = "Domain name for the labs UI (optional, leave empty to skip ingress)"
  type        = string
  default     = ""
}

variable "spot_instance_types" {
  description = "Instance types for spot node group (ordered by preference)"
  type        = list(string)
  default     = ["t3.small", "t3a.small", "t3.micro", "t3a.micro"]
}

variable "workspace_instance_types" {
  description = "Instance types for workspace node group (needs more resources for lab workloads)"
  type        = list(string)
  default     = ["t3.small", "t3a.small", "m5.small", "m5a.small"]
}

variable "min_nodes" {
  description = "Minimum number of nodes in the app node group"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes in the app node group"
  type        = number
  default     = 3
}

variable "workspace_min_nodes" {
  description = "Minimum number of nodes in the workspace node group"
  type        = number
  default     = 0
}

variable "workspace_max_nodes" {
  description = "Maximum number of nodes in the workspace node group"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "cks-practice-labs"
    ManagedBy   = "terraform"
    Environment = "dev"
    CostCenter  = "training"
  }
}
