# Getting Started — CKS Practice Labs

A step-by-step guide to running the lab platform end-to-end.

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| AWS CLI | >= 2.x | AWS authentication & ECR login |
| Terraform | >= 1.5 | Infrastructure provisioning |
| Docker | >= 24.x | Building container images |
| kubectl | >= 1.28 | Kubernetes cluster access |
| Node.js | >= 20.x | Local UI development (optional) |

You also need:
- An AWS account with admin-level IAM permissions (VPC, EKS, ECR, IAM)
- An AWS CLI profile configured (`aws configure`)
- An S3 bucket for Terraform state (or use local state for testing)

---

## Option A: Full Deployment (EKS + Terminal)

### 1. Configure Terraform

```bash
cd cks-practice-labs/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
region       = "eu-west-2"       # your preferred region
cluster_name = "cks-practice-labs"
```

For the S3 backend, uncomment and fill in the `backend "s3"` block in `versions.tf`:
```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "cks-practice-labs/terraform.tfstate"
  region         = "eu-west-2"
  dynamodb_table = "terraform-locks"
  encrypt        = true
}
```

Or remove the `backend "s3" {}` block entirely to use local state.

### 2. Spin Up Infrastructure

```bash
make infra-init    # terraform init
make infra-up      # creates VPC + EKS + addons (~15-20 min)
```

This provisions:
- VPC with public/private subnets, single NAT gateway
- EKS cluster with two spot node groups (app + workspace)
- Cluster Autoscaler (scales workspace nodes to 0 when idle)
- AWS Load Balancer Controller (ALB ingress)
- ArgoCD

### 3. Connect kubectl

```bash
make kubeconfig
# Equivalent to: aws eks update-kubeconfig --name cks-practice-labs --region eu-west-2
```

Verify:
```bash
kubectl get nodes
```

### 4. Create ECR Repos

```bash
make ecr-create
```

This creates two repositories:
- `cks-practice-labs` (the UI)
- `cks-workspace` (the terminal workspace)

### 5. Build & Push Docker Images

```bash
make images        # builds both Docker images locally
make push-all      # pushes to ECR
```

### 6. Update Image References

Get your ECR URI:
```bash
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
echo "${AWS_ACCOUNT}.dkr.ecr.eu-west-2.amazonaws.com"
```

Edit these files and replace `YOUR_ECR_REPO` with your ECR URI:
- `k8s/deployment.yaml` → image field
- `k8s/workspace/deployment.yaml` → image field

### 7. Deploy to EKS

```bash
make deploy
```

### 8. Access the Platform

**Option A — Port forward (no domain needed):**
```bash
make port-forward
```
- UI: http://localhost:3000
- Terminal: http://localhost:7681 (also embedded in the UI)

**Option B — Via domain (requires DNS + cert):**
- Update `k8s/ingress.yaml` with your domain
- Access via ALB URL shown in `kubectl get ingress -A`

---

## Option B: UI Only (Local, No Cluster)

If you just want to browse questions, read solutions, and track progress:

```bash
cd cks-practice-labs
npm install
npm run dev
```

Open http://localhost:3000

The terminal panel won't function (no workspace pod), but all lab content, navigation, hints, solutions, and progress tracking work.

---

## Using the Labs

### Workflow

1. Open the UI and select a question from the sidebar
2. Read the **Given** context and **Requirements**
3. Click **"Start Lab (Open Terminal)"** to open the embedded terminal
4. In the terminal, initialize the lab:
   ```bash
   setup-lab 07
   ```
5. Solve the question using kubectl, vim, etc. in the terminal
6. Verify your solution:
   ```bash
   verify-lab 07
   ```
   Output shows PASS/FAIL for each verification check.
7. Mark your result in the UI: **✓ Mark Passed** / **✗ Mark Failed**
8. Clean up the environment:
   ```bash
   cleanup-lab 07
   ```
9. Click **Next →** for the next question

### Terminal Commands

| Command | Description |
|---------|-------------|
| `setup-lab <num>` | Initialize lab environment (creates namespaces, pods, resources) |
| `verify-lab <num>` | Run verification checks against your solution |
| `cleanup-lab <num>` | Tear down the lab environment |
| `k` | Alias for `kubectl` |
| `kn <namespace>` | Set current kubectl namespace |

### Tips

- Use **Hints** (collapsible) before revealing the solution
- The **Verification Checks** section shows exactly what `verify-lab` tests
- Solutions are hidden by default — click **🔒 Answer / Solution** to reveal
- Your progress (passed/failed/in-progress) persists in the browser

---

## Cost Management

### Idle Costs (~$3-5/day)
- EKS control plane: $0.10/hr ($2.40/day)
- 1x t3.medium spot app node: ~$0.01-0.02/hr
- NAT gateway: $0.045/hr + data

### Active Costs (~$5-8/day)
- Above + 1x t3.large workspace node when labs are running

### Saving Money
- Workspace nodes scale to 0 automatically after 5 minutes of no pods
- Run `make down` to destroy everything when not studying
- Use `make infra-up` to spin back up (takes ~15 min)
- All nodes are spot instances (60-90% cheaper than on-demand)

---

## Deploying via ArgoCD (GitOps)

If you prefer GitOps over manual `kubectl apply`:

1. Push this repo to GitHub/GitLab
2. Edit `k8s/argocd-application.yaml`:
   - Set `repoURL` to your git repo
   - Set `targetRevision` to your branch
3. Apply:
   ```bash
   make deploy-argocd
   ```
4. Access ArgoCD UI:
   ```bash
   make argocd-ui
   # Username: admin
   # Password shown in terminal output
   ```

Now any push to `main` auto-deploys changes.

---

## Teardown

```bash
make down    # terraform destroy — removes ALL AWS resources
```

This destroys the EKS cluster, VPC, NAT gateway, node groups — everything. Your Terraform state is preserved in S3 so you can `make infra-up` again later.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `kubectl get nodes` shows nothing | Run `make kubeconfig` again |
| Workspace pod pending | Workspace node group is scaling up from 0. Wait 2-3 min. |
| Terminal iframe blank | Check workspace pod: `kubectl get pods -n cks-workspace` |
| ECR push fails | Run `aws ecr get-login-password --region eu-west-2 \| docker login --username AWS --password-stdin <ecr-uri>` |
| Terraform fails on destroy | Some resources may need manual deletion (ALB, security groups) |
| API server 401 | kubeconfig expired. Run `make kubeconfig` |
