#!/bin/bash
echo "[*] Setting up Q10 — Enable Audit Logging"
echo ""

kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create namespace billing --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Create test resources
kubectl create secret generic billing-secret --from-literal=key=value -n billing 2>/dev/null || true
kubectl run web --image=nginx:1.25 -n prod 2>/dev/null || true

mkdir -p /var/work/tests/artifacts/13/

echo "[✓] Namespaces 'prod' and 'billing' created with test resources"
echo ""
echo "Task:"
echo "  1. Create an audit policy at /etc/kubernetes/audit/policy.yaml with rules:"
echo "     - Nothing from stage 'RequestReceived'"
echo "     - Nothing from 'system:kube-proxy'"
echo "     - Level 'Nothing' for get/list/watch on secrets in namespace 'billing'"
echo "     - Level 'Metadata' for secrets in all namespaces"
echo "     - Level 'RequestResponse' for changes to configmaps and deployments in 'prod'"
echo "     - Catch-all: Level 'Metadata'"
echo "  2. Configure kube-apiserver with audit flags:"
echo "     - --audit-policy-file=/etc/kubernetes/audit/policy.yaml"
echo "     - --audit-log-path=/etc/kubernetes/audit/logs/audit.log"
echo "     - --audit-log-maxsize=5"
echo "     - --audit-log-maxbackup=1"
echo "  3. Wait for apiserver to restart, then save first 3 audit entries to:"
echo "     /var/work/tests/artifacts/13/audit-entries.json"
