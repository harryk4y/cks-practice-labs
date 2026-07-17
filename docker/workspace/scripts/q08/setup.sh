#!/bin/bash
echo "[*] Setting up Q08 — Container Runtime Sandbox gVisor"
echo ""

kubectl create namespace team-purple --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Create sample deployments in team-purple
kubectl create deployment web-purple --image=nginx:1.25 -n team-purple --replicas=1 2>/dev/null || true
kubectl create deployment api-purple --image=busybox -n team-purple --replicas=1 -- sleep 3600 2>/dev/null || true

mkdir -p /var/work/tests/artifacts/10/

echo "[✓] Namespace 'team-purple' created with deployments: web-purple, api-purple"
echo ""
echo "Task:"
echo "  1. Create a RuntimeClass named 'gvisor' with handler 'runsc'"
echo "  2. Update ALL deployments in team-purple to use the 'gvisor' RuntimeClass"
echo "  3. Run 'dmesg' inside one of the pods and save output to /var/work/tests/artifacts/10/dmesg.txt"
echo ""
echo "Cluster: cluster1"
