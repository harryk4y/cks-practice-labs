.PHONY: help dev build docker-build docker-push infra-up infra-down infra-plan workspace-build workspace-push deploy

REGION ?= eu-west-2
CLUSTER_NAME ?= cks-practice-labs
ECR_REPO ?= $(shell aws sts get-caller-identity --query Account --output text).dkr.ecr.$(REGION).amazonaws.com
APP_IMAGE = $(ECR_REPO)/cks-practice-labs
WORKSPACE_IMAGE = $(ECR_REPO)/cks-workspace
TAG ?= latest

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ─── Local Development ───────────────────────────────────────────────────────

dev: ## Run Next.js dev server locally
	npm run dev

build: ## Build Next.js production
	npm run build

# ─── Docker ──────────────────────────────────────────────────────────────────

docker-build: ## Build the app Docker image
	docker build --platform linux/amd64 -t $(APP_IMAGE):$(TAG) .

docker-push: ## Push app image to ECR
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_REPO)
	docker push $(APP_IMAGE):$(TAG)

workspace-build: ## Build the workspace Docker image
	docker build --platform linux/amd64 -t $(WORKSPACE_IMAGE):$(TAG) docker/workspace/

workspace-push: ## Push workspace image to ECR
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_REPO)
	docker push $(WORKSPACE_IMAGE):$(TAG)

images: docker-build workspace-build ## Build all Docker images

push-all: docker-push workspace-push ## Push all images to ECR

# ─── Infrastructure ──────────────────────────────────────────────────────────

infra-init: ## Initialize Terraform
	cd terraform && terraform init

infra-plan: ## Plan infrastructure changes
	cd terraform && terraform plan

infra-up: ## Spin up all infrastructure (EKS + addons)
	cd terraform && terraform apply -auto-approve
	@echo ""
	@echo "╔══════════════════════════════════════════════╗"
	@echo "║  Infrastructure is UP                        ║"
	@echo "╠══════════════════════════════════════════════╣"
	@echo "║  Run: make kubeconfig                        ║"
	@echo "║  Then: make deploy                           ║"
	@echo "╚══════════════════════════════════════════════╝"

infra-down: ## Tear down all infrastructure
	cd terraform && terraform destroy -auto-approve
	@echo ""
	@echo "╔══════════════════════════════════════════════╗"
	@echo "║  Infrastructure DESTROYED                    ║"
	@echo "╚══════════════════════════════════════════════╝"

infra-output: ## Show Terraform outputs
	cd terraform && terraform output

# ─── Kubernetes ──────────────────────────────────────────────────────────────

kubeconfig: ## Configure kubectl for the EKS cluster
	aws eks update-kubeconfig --name $(CLUSTER_NAME) --region $(REGION)

deploy: ## Deploy app + workspace to EKS
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml
	kubectl apply -f k8s/workspace/namespace.yaml
	kubectl apply -f k8s/workspace/rbac.yaml
	kubectl apply -f k8s/workspace/deployment.yaml
	kubectl apply -f k8s/ingress.yaml
	@echo ""
	@echo "Deployed! Waiting for pods..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cks-practice-labs -n cks-practice-labs --timeout=120s || true

deploy-argocd: ## Deploy via ArgoCD Application
	kubectl apply -f k8s/argocd-application.yaml

port-forward: ## Port-forward the app locally (http://localhost:3000)
	@echo "App: http://localhost:3000"
	@echo "Terminal: http://localhost:7681"
	kubectl port-forward svc/cks-practice-labs -n cks-practice-labs 3000:80 &
	kubectl port-forward svc/workspace -n cks-workspace 7681:7681 &

argocd-ui: ## Port-forward ArgoCD UI (https://localhost:8080)
	@echo "ArgoCD: https://localhost:8080"
	@echo "Username: admin"
	@echo "Password: $$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
	kubectl port-forward svc/argocd-server -n argocd 8080:443

# ─── ECR Setup ───────────────────────────────────────────────────────────────

ecr-create: ## Create ECR repositories (now handled by Terraform, kept for manual use)
	@echo "ECR repos are created automatically by 'make infra-up' (terraform/ecr.tf)"
	@echo "If you need to create them manually:"
	aws ecr create-repository --repository-name cks-practice-labs --region $(REGION) --image-scanning-configuration scanOnPush=true || true
	aws ecr create-repository --repository-name cks-workspace --region $(REGION) --image-scanning-configuration scanOnPush=true || true

# ─── Full Lifecycle ──────────────────────────────────────────────────────────

up: infra-up kubeconfig images push-all deploy ## Full spin-up: infra + build + deploy
	@echo ""
	@echo "╔══════════════════════════════════════════════╗"
	@echo "║  CKS Practice Labs is LIVE!                  ║"
	@echo "║  Run: make port-forward                      ║"
	@echo "╚══════════════════════════════════════════════╝"

down: infra-down ## Full teardown: destroy all infrastructure
