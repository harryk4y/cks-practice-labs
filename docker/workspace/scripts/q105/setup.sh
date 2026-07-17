#!/bin/bash
echo "[*] Setting up Q105 (Mock) — Secrets Management"
echo ""

kubectl create namespace team-alpha --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

kubectl create secret generic app-credentials \
  --from-literal=username=admin \
  --from-literal=password=SuperS3cret! \
  -n team-alpha 2>/dev/null || true

kubectl create secret generic db-credentials \
  --from-literal=host=db.internal \
  --from-literal=port=5432 \
  --from-literal=password=DbP@ss123 \
  -n team-alpha 2>/dev/null || true

mkdir -p /var/work/tests/artifacts/mock/105/

echo "[✓] Namespace 'team-alpha' created with secrets"
echo ""
echo "Task:"
echo "  1. Extract the password from secret 'app-credentials' in team-alpha"
echo "     Save decoded value to /var/work/tests/artifacts/mock/105/app-password.txt"
echo ""
echo "  2. Extract the host from secret 'db-credentials' in team-alpha"
echo "     Save decoded value to /var/work/tests/artifacts/mock/105/db-host.txt"
echo ""
echo "  3. Create a new secret 'combined-creds' in team-alpha with:"
echo "     - app-user=admin"
echo "     - db-connection=db.internal:5432"
echo ""
echo "Hint: kubectl get secret <name> -n team-alpha -o jsonpath='{.data.<key>}' | base64 -d"
echo ""
echo "Weight: 5%"
