#!/bin/bash
echo "[*] Setting up Q103 (Mock) — Audit Logging"
echo ""

kubectl create namespace payments --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create namespace internal --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

kubectl create secret generic api-key --from-literal=key=mock-key -n payments 2>/dev/null || true
kubectl run web -n internal --image=nginx:1.25 2>/dev/null || true

mkdir -p /var/work/tests/artifacts/mock/103/

echo "[✓] Namespaces 'payments' and 'internal' created"
echo ""
echo "Task:"
echo "  Configure API server audit logging."
echo ""
echo "  1. Create audit policy at /etc/kubernetes/audit/policy.yaml:"
echo "     - Omit RequestReceived stage"
echo "     - Level 'Nothing' for read operations on secrets in 'payments'"
echo "     - Level 'Metadata' for all secret operations"
echo "     - Level 'RequestResponse' for configmaps and deployments in 'internal'"
echo "     - Catch-all: Level 'Metadata'"
echo ""
echo "  2. Configure apiserver with:"
echo "     --audit-policy-file=/etc/kubernetes/audit/policy.yaml"
echo "     --audit-log-path=/etc/kubernetes/audit/logs/audit.log"
echo "     --audit-log-maxsize=7"
echo "     --audit-log-maxbackup=2"
echo ""
echo "  3. Save first 2 audit entries to /var/work/tests/artifacts/mock/103/audit.json"
echo ""
echo "Weight: 7%"
