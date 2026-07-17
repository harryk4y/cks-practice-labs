#!/bin/bash
echo "[*] Setting up Q22 — Istio mTLS Policy"
echo ""

kubectl create namespace market --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl label ns market istio-injection=enabled --overwrite 2>/dev/null

# Create app and db pods
kubectl run market-app -n market --image=nginx:1.25 --labels="app=market-app,tier=frontend" 2>/dev/null || true
kubectl run market-db -n market --image=busybox --labels="app=market-db,tier=backend" -- sleep 3600 2>/dev/null || true

echo "[✓] Namespace 'market' created with pods: market-app, market-db"
echo "[✓] Istio injection label added to namespace"
echo ""
echo "Task:"
echo "  Configure Istio PeerAuthentication to enforce STRICT mTLS in the 'market' namespace."
echo ""
echo "  Create PeerAuthentication resource:"
echo "    apiVersion: security.istio.io/v1beta1"
echo "    kind: PeerAuthentication"
echo "    metadata:"
echo "      name: strict-mtls"
echo "      namespace: market"
echo "    spec:"
echo "      mtls:"
echo "        mode: STRICT"
echo ""
echo "  Verify with:"
echo "    kubectl get peerauthentication -n market"
