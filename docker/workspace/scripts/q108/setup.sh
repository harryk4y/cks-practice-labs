#!/bin/bash
echo "[*] Setting up Q108 (Mock) — Network Policy (Default Deny + Allow)"
echo ""

kubectl create namespace secure-app --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create namespace trusted --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

kubectl label ns monitoring purpose=monitoring --overwrite 2>/dev/null
kubectl label ns trusted purpose=trusted --overwrite 2>/dev/null

kubectl run app-server -n secure-app --image=nginx:1.25 --labels="app=server" 2>/dev/null || true
kubectl run metrics -n monitoring --image=busybox --labels="app=metrics" -- sleep 3600 2>/dev/null || true
kubectl run trusted-client -n trusted --image=busybox --labels="app=client" -- sleep 3600 2>/dev/null || true

echo "[✓] Namespaces created: secure-app, monitoring, trusted"
echo "[✓] Pods created: app-server (secure-app), metrics (monitoring), trusted-client (trusted)"
echo ""
echo "Task:"
echo "  1. Create a default-deny-all NetworkPolicy in 'secure-app' namespace:"
echo "     - Name: default-deny"
echo "     - Deny all ingress and egress"
echo ""
echo "  2. Create a NetworkPolicy to allow ingress from 'monitoring' and 'trusted' namespaces:"
echo "     - Name: allow-from-namespaces"
echo "     - Allow ingress to app=server from namespaces with purpose=monitoring"
echo "     - Allow ingress to app=server from namespaces with purpose=trusted"
echo "     - Allow egress to DNS (port 53 UDP)"
echo ""
echo "Weight: 7%"
