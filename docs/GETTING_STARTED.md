# Getting Started — CKS Practice Labs

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| AWS CLI | >= 2.x | AWS authentication & ECR login |
| Terraform | >= 1.5 | Infrastructure provisioning |
| Docker | >= 24.x | Building container images (local builds) |
| kubectl | >= 1.28 | Kubernetes cluster access |
| Node.js | >= 20.x | Local UI development (optional) |

You also need:
- An AWS account with IAM permissions (VPC, EKS, ECR, IAM)
- An AWS CLI profile configured (`aws configure`)

---

## Deployment Options

### Option 1: CI/CD Pipeline (Recommended)

Push this repo to GitHub and use the built-in GitHub Actions workflows.

**One-time setup:**

1. Add these GitHub repository secrets:
   - `AWS_ACCOUNT_ID` — your AWS account ID (e.g., `880145880830`)
   - `AWS_ROLE_ARN` — IAM role ARN with OIDC trust for GitHub Actions

2. Deploy infrastructure:
   - Go to **Actions** → **Infrastructure** → **Run workflow**
   - Select `apply` → Run
   - This creates: VPC, EKS, ECR repos, ArgoCD, ALB controller, cluster autoscaler

3. Build and deploy the app:
   - Go to **Actions** → **Build & Deploy** → **Run workflow**
   - Select `all` + deploy = `true` → Run
   - This builds both images (linux/amd64) → pushes to ECR → deploys to EKS

4. Access:
   ```bash
   aws eks update-kubeconfig --name cks-practice-labs --region eu-west-2
   kubectl port-forward svc/cks-practice-labs -n cks-practice-labs 3001:80
   kubectl port-forward svc/workspace -n cks-workspace 7681:7681
   ```
   - UI: http://localhost:3001
   - Terminal: http://localhost:7681/terminal/

**Subsequent deploys:** Just click "Run workflow" on **Build & Deploy** — no local Docker needed.

---

### Option 2: Local CLI (`make up`)

Single command that does everything:

```bash
make up
```

This runs:
1. `terraform apply` — creates VPC, EKS, ECR repos, addons
2. `aws eks update-kubeconfig` — connects kubectl
3. `docker build --platform linux/amd64` — builds both images
4. `docker push` — pushes to ECR
5. `kubectl apply` — deploys to EKS

Then access:
```bash
make port-forward
# UI: http://localhost:3001
# Terminal: http://localhost:7681
```

---

### Option 3: UI Only (No Cluster)

Browse questions, solutions, and track progress locally without AWS:

```bash
npm install
npm run dev
```

Open http://localhost:3000. The terminal panel won't function (no workspace pod).

---

## Step-by-Step (Manual)

If you prefer doing it piece by piece:

```bash
# 1. Deploy infrastructure (creates EKS + ECR + addons)
make infra-init
make infra-up        # ~15-20 minutes

# 2. Connect kubectl
make kubeconfig

# 3. Build images (must use --platform linux/amd64 on Mac)
make images

# 4. Push to ECR
make push-all

# 5. Deploy to EKS
make deploy

# 6. Access
make port-forward
```

---

## Using the Labs

### Workflow

1. Open the UI (http://localhost:3001)
2. Select a question from the sidebar
3. Click **"Start Lab (Open Terminal)"**
4. In the terminal, run:
   ```bash
   setup-lab 4
   ```
5. Solve the question using kubectl, vim, etc.
6. Verify your solution:
   ```bash
   verify-lab 4
   ```
7. Mark result in the UI: **✓ Mark Passed** / **✗ Mark Failed**
8. Clean up:
   ```bash
   cleanup-lab 4
   ```
9. Click **Next →**

### Terminal Commands

| Command | Description |
|---------|-------------|
| `setup-lab <num>` | Initialize lab environment |
| `verify-lab <num>` | Run verification checks |
| `cleanup-lab <num>` | Tear down lab environment |
| `k` | Alias for `kubectl` |
| `kn <namespace>` | Set current namespace |

---

## Cost Management

| State | Estimated Cost |
|-------|---------------|
| Idle (no labs running) | ~$3-5/day |
| Active (workspace node up) | ~$5-8/day |
| Destroyed | $0 |

**Cost savers already configured:**
- Spot instances (60-90% cheaper)
- Workspace nodes scale to 0 after 5 min idle
- Single NAT gateway
- ECR lifecycle policy keeps only 5 images

**When done studying:**
```bash
make down    # Destroys ALL AWS resources
```

Re-create anytime with `make up` (~15 min).

---

## CI/CD Workflows

| Workflow | Trigger | Options |
|----------|---------|---------|
| **Build & Deploy** | Manual (Actions tab) | `all` / `app-only` / `workspace-only` + deploy toggle |
| **Infrastructure** | Manual (Actions tab) | `plan` / `apply` / `destroy` |

### GitHub Secrets Required

| Secret | Value |
|--------|-------|
| `AWS_ACCOUNT_ID` | Your AWS account ID |
| `AWS_ROLE_ARN` | IAM role with OIDC trust for GitHub Actions |

To create the OIDC role, see: [GitHub OIDC with AWS](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

---

## Teardown

```bash
make down
```

Or via GitHub Actions → **Infrastructure** → `destroy`.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `exec format error` in pod | Image built for ARM. Rebuild with `--platform linux/amd64` |
| Pods stuck in Pending | Nodes full (t3.small = 8 pod limit). Scale down ArgoCD or add nodes |
| Port 3000 taken | Use port 3001: `kubectl port-forward ... 3001:80` |
| `setup-lab` not found | Workspace image needs rebuild (bashrc_append not sourced) |
| ECR push 403 | Run `aws ecr get-login-password --region eu-west-2 \| docker login ...` |
| Terraform: "not authorized to launch" | Account restricts instance types. Use t3.small/t3.micro |
| Docker client version too old | Run `brew unlink docker` to use Docker Desktop's CLI |
