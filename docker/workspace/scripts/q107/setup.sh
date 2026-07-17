#!/bin/bash
echo "[*] Setting up Q107 (Mock) — ETCD Encryption"
echo ""

kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

kubectl create secret generic dev-secret-1 --from-literal=data=value1 -n dev 2>/dev/null || true
kubectl create secret generic dev-secret-2 --from-literal=data=value2 -n dev 2>/dev/null || true

echo "[✓] Namespace 'dev' created with sample secrets"
echo ""
echo "Task:"
echo "  Configure encryption at rest for secrets stored in ETCD."
echo ""
echo "  1. Create encryption config at /etc/kubernetes/enc/enc.yaml:"
echo "     apiVersion: apiserver.config.k8s.io/v1"
echo "     kind: EncryptionConfiguration"
echo "     resources:"
echo "     - resources:"
echo "       - secrets"
echo "       providers:"
echo "       - aescbc:"
echo "           keys:"
echo "           - name: key1"
echo "             secret: <base64-encoded-32-byte-key>"
echo "       - identity: {}"
echo ""
echo "  2. Add to kube-apiserver:"
echo "     --encryption-provider-config=/etc/kubernetes/enc/enc.yaml"
echo ""
echo "  3. Create a new test secret after encryption is active:"
echo "     kubectl create secret generic enc-test --from-literal=data=encrypted -n dev"
echo ""
echo "  4. Re-encrypt existing secrets:"
echo "     kubectl get secrets -n dev -o json | kubectl replace -f -"
echo ""
echo "Weight: 6%"
