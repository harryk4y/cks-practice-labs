#!/bin/bash
echo "[*] Setting up Q14 — Network Policy Multi-tier"
echo ""

# Create namespaces
kubectl create namespace prod-stack-1 --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create namespace prod-db --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Label namespaces
kubectl label ns prod-stack-1 app=prod-stack-1 --overwrite 2>/dev/null
kubectl label ns prod-db app=prod-db --overwrite 2>/dev/null

# Create frontend in prod-stack-1
kubectl run frontend -n prod-stack-1 --image=nginx:1.25 --labels="tier=frontend" 2>/dev/null || true

# Create backend in prod-stack-1
kubectl run backend -n prod-stack-1 --image=nginx:1.25 --labels="tier=backend" 2>/dev/null || true

# Create mysql in prod-db
kubectl run mysql -n prod-db --image=busybox --labels="tier=db,app=mysql" -- sleep 3600 2>/dev/null || true

# Create user-client in prod-stack-1
kubectl run user-client -n prod-stack-1 --image=busybox --labels="tier=client,app=user-client" -- sleep 3600 2>/dev/null || true

echo "[✓] Created namespaces: prod-stack-1, prod-db"
echo "[✓] Created pods: frontend, backend (prod-stack-1), mysql (prod-db), user-client (prod-stack-1)"
echo ""
echo "Task: Create NetworkPolicies with the following rules:"
echo ""
echo "  1. In namespace 'prod-stack-1':"
echo "     - Name: np-frontend"
echo "     - frontend can only receive traffic from user-client"
echo "     - frontend can only send traffic to backend"
echo ""
echo "  2. In namespace 'prod-stack-1':"
echo "     - Name: np-backend"
echo "     - backend can only receive from frontend"
echo "     - backend can only send traffic to mysql in prod-db"
echo ""
echo "  3. In namespace 'prod-db':"
echo "     - Name: np-mysql"
echo "     - mysql can only receive from backend in prod-stack-1"
echo "     - mysql cannot send any egress traffic"
