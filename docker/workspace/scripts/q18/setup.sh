#!/bin/bash
echo "[*] Setting up Q18 — Cilium with WireGuard"
echo ""

kubectl create namespace external --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create namespace finance --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

kubectl run external-web -n external --image=nginx:1.25 --labels="app=web" 2>/dev/null || true
kubectl run finance-app -n finance --image=nginx:1.25 --labels="app=finance" 2>/dev/null || true

echo "[✓] Namespaces 'external' and 'finance' created with pods"
echo ""
echo "Task:"
echo "  Install Cilium CNI with WireGuard encryption enabled."
echo ""
echo "Steps:"
echo "  1. Install Cilium with Helm:"
echo "     helm install cilium cilium/cilium --version 1.15.0 \\"
echo "       --namespace kube-system \\"
echo "       --set encryption.enabled=true \\"
echo "       --set encryption.type=wireguard \\"
echo "       --set encryption.nodeEncryption=true"
echo ""
echo "  2. Verify Cilium is running:"
echo "     cilium status"
echo ""
echo "  3. Verify encryption:"
echo "     cilium encrypt status"
echo ""
echo "  4. Test connectivity between namespaces:"
echo "     kubectl exec finance-app -n finance -- curl external-web.external.svc.cluster.local"
