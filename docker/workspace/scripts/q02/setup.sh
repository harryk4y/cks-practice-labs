#!/bin/bash
echo "[*] Setting up Q02 — Falco / Sysdig Logging"
echo ""
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl run nginx-target --image=nginx:latest -n monitoring --restart=Never 2>/dev/null || true
mkdir -p /var/work/tests/artifacts/12/
echo "[✓] Nginx pod created in monitoring namespace"
echo ""
echo "Task: Use sysdig/falco to capture logs for the nginx pod"
echo "Format: time-with-nanoseconds,container-id,container-name,user-name,k8s-namespace,k8s-pod-name"
echo "Save to: /var/work/tests/artifacts/12/log"
