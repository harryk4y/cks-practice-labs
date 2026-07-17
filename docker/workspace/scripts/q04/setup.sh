#!/bin/bash
echo "[*] Setting up Q04 — Pod Security Standard"
echo ""
kubectl create namespace team-red --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create deployment insecure-app --image=nginx:latest -n team-red --replicas=1 2>/dev/null || true

# Make the deployment violate baseline PSS (privileged)
kubectl patch deploy insecure-app -n team-red --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/securityContext","value":{"privileged":true}}]' 2>/dev/null || true

mkdir -p /var/work/tests/artifacts/4/
echo "[✓] Namespace team-red created with insecure deployment"
echo ""
echo "Task:"
echo "  1. Enforce baseline Pod Security Standard on team-red namespace"
echo "  2. Delete the pods"
echo "  3. Save ReplicaSet events to /var/work/tests/artifacts/4/events.log"
