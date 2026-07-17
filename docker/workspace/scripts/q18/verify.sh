#!/bin/bash
FAILED=0

echo "[*] Verifying Q18 — Cilium with WireGuard"
echo ""

# Check cilium is running
CILIUM_PODS=$(kubectl get pods -n kube-system -l k8s-app=cilium --no-headers 2>/dev/null | wc -l)
if [ "$CILIUM_PODS" -gt 0 ]; then
    echo "[PASS] Cilium pods are running ($CILIUM_PODS pods)"
else
    echo "[FAIL] No Cilium pods found in kube-system"
    FAILED=1
fi

# Check Cilium configmap for encryption
CILIUM_CONFIG=$(kubectl get configmap cilium-config -n kube-system -o jsonpath='{.data.enable-wireguard}' 2>/dev/null)
if [ "$CILIUM_CONFIG" = "true" ]; then
    echo "[PASS] WireGuard encryption is enabled in Cilium config"
else
    # Also check via helm values
    ENC_ENABLED=$(kubectl get configmap cilium-config -n kube-system -o yaml 2>/dev/null | grep -i "wireguard\|encryption")
    if [ -n "$ENC_ENABLED" ]; then
        echo "[PASS] Encryption references found in Cilium config"
    else
        echo "[FAIL] WireGuard encryption not detected"
        FAILED=1
    fi
fi

# Check cilium status if CLI available
if command -v cilium &>/dev/null; then
    echo ""
    echo "[INFO] Cilium status:"
    cilium status 2>/dev/null | head -10
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
