#!/bin/bash
echo "[*] Setting up Q111 (Mock) — RBAC Roles and Bindings"
echo ""

kubectl create namespace dev-team --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Create service accounts
kubectl create serviceaccount developer -n dev-team 2>/dev/null || true
kubectl create serviceaccount deployer -n dev-team 2>/dev/null || true

# Create some resources for them to manage
kubectl run test-pod -n dev-team --image=nginx:1.25 2>/dev/null || true
kubectl create deployment test-deploy -n dev-team --image=nginx:1.25 2>/dev/null || true

echo "[✓] Namespace 'dev-team' with service accounts: developer, deployer"
echo ""
echo "Task:"
echo "  Create RBAC Roles and RoleBindings for the following access:"
echo ""
echo "  1. Role: pod-reader"
echo "     - Namespace: dev-team"
echo "     - Permissions: get, list, watch on pods and pods/log"
echo "     - Bind to: ServiceAccount 'developer' in dev-team"
echo "     - RoleBinding name: developer-pod-reader"
echo ""
echo "  2. Role: deployment-manager"
echo "     - Namespace: dev-team"
echo "     - Permissions: get, list, watch, create, update, patch, delete on deployments"
echo "     - Permissions: get, list on pods, replicasets"
echo "     - Bind to: ServiceAccount 'deployer' in dev-team"
echo "     - RoleBinding name: deployer-deployment-manager"
echo ""
echo "  3. Verify access:"
echo "     kubectl auth can-i get pods --as=system:serviceaccount:dev-team:developer -n dev-team"
echo "     kubectl auth can-i create deployments --as=system:serviceaccount:dev-team:deployer -n dev-team"
echo ""
echo "Weight: 5%"
