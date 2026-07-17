#!/bin/bash
FAILED=0

echo "[*] Verifying Q12 — Kubernetes Cluster Upgrade"
echo ""

# Check node versions
echo "Current node versions:"
kubectl get nodes -o wide 2>/dev/null

# Check if any node is on 1.29.1
VERSIONS=$(kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.kubeletVersion}' 2>/dev/null)
if echo "$VERSIONS" | grep -q "1.29.1"; then
    echo ""
    echo "[PASS] At least one node is running v1.29.1"
else
    echo ""
    echo "[FAIL] No nodes running v1.29.1. Current versions: $VERSIONS"
    FAILED=1
fi

# Check kubectl version
KUBECTL_VER=$(kubectl version --short 2>/dev/null | grep "Server" || kubectl version 2>/dev/null | grep "Server")
echo "[INFO] Server version: $KUBECTL_VER"

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
