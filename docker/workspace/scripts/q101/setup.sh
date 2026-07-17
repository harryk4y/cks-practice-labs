#!/bin/bash
echo "[*] Setting up Q101 (Mock) — Container Runtime Sandbox gVisor"
echo ""

kubectl create namespace team-gold --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

kubectl create deployment app-gold --image=nginx:1.25 -n team-gold --replicas=1 2>/dev/null || true
kubectl create deployment cache-gold --image=busybox -n team-gold --replicas=1 -- sleep 3600 2>/dev/null || true

mkdir -p /var/work/tests/artifacts/mock/101/

echo "[✓] Namespace 'team-gold' created with deployments: app-gold, cache-gold"
echo ""
echo "Task:"
echo "  1. Create a RuntimeClass named 'gvisor' with handler 'runsc'"
echo "  2. Update ALL deployments in team-gold to use the 'gvisor' RuntimeClass"
echo "  3. Exec into one pod and run 'dmesg', save to /var/work/tests/artifacts/mock/101/dmesg.txt"
echo ""
echo "Cluster: cluster1"
echo "Weight: 4%"
