#!/bin/bash
echo "[*] Setting up Q09 — Secrets in ETCD"
echo ""

kubectl create namespace team-green --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Create the secret
kubectl create secret generic database-access \
  --from-literal=user=db-admin \
  --from-literal=pass=s3cr3t-p@ss! \
  -n team-green 2>/dev/null || true

mkdir -p /var/work/tests/artifacts/11/

echo "[✓] Namespace 'team-green' created with secret 'database-access'"
echo ""
echo "Task:"
echo "  1. Read the secret 'database-access' in namespace 'team-green' directly from ETCD"
echo "     Use: ETCDCTL_API=3 etcdctl ... get /registry/secrets/team-green/database-access"
echo "  2. Save the ETCD output to /var/work/tests/artifacts/11/etcd-secret-output.txt"
echo "  3. Decode the secret value and save to /var/work/tests/artifacts/11/decoded-secret.txt"
echo ""
echo "Hint: You'll need the etcd certs from /etc/kubernetes/pki/etcd/"
echo "      --cacert, --cert, --key"
