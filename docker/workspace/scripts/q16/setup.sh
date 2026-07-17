#!/bin/bash
echo "[*] Setting up Q16 — Encrypt Secrets in ETCD"
echo ""

kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create namespace stage --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Create sample secrets in stage
kubectl create secret generic stage-secret-1 --from-literal=key=value1 -n stage 2>/dev/null || true
kubectl create secret generic stage-secret-2 --from-literal=key=value2 -n stage 2>/dev/null || true
kubectl create secret generic prod-secret --from-literal=key=prodvalue -n prod 2>/dev/null || true

mkdir -p /var/work/tests/artifacts/16/

echo "[✓] Namespaces 'prod' and 'stage' created with sample secrets"
echo ""
echo "Task:"
echo "  1. Create an EncryptionConfiguration at /etc/kubernetes/enc/enc.yaml:"
echo "     - Use aescbc provider with a base64-encoded key"
echo "     - Resources: secrets"
echo "  2. Configure kube-apiserver with:"
echo "     --encryption-provider-config=/etc/kubernetes/enc/enc.yaml"
echo "  3. After apiserver restarts, create a new secret:"
echo "     kubectl create secret generic test-secret --from-literal=data=encrypted -n prod"
echo "  4. Re-encrypt all existing secrets in 'stage' namespace:"
echo "     kubectl get secrets -n stage -o json | kubectl replace -f -"
echo "  5. Verify encryption by reading from etcd directly"
