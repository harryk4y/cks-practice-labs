#!/bin/bash
FAILED=0

echo "[*] Verifying Q108 (Mock) — Network Policy (Default Deny + Allow)"
echo ""

# Check default-deny policy
if kubectl get networkpolicy default-deny -n secure-app &>/dev/null; then
    echo "[PASS] NetworkPolicy default-deny exists in secure-app"
    # Verify it's a deny-all
    TYPES=$(kubectl get networkpolicy default-deny -n secure-app -o jsonpath='{.spec.policyTypes}' 2>/dev/null)
    if echo "$TYPES" | grep -q "Ingress" && echo "$TYPES" | grep -q "Egress"; then
        echo "[PASS] default-deny covers both Ingress and Egress"
    else
        echo "[WARN] default-deny may not cover both Ingress and Egress: $TYPES"
    fi
else
    echo "[FAIL] NetworkPolicy default-deny not found in secure-app"
    FAILED=1
fi

# Check allow policy
if kubectl get networkpolicy allow-from-namespaces -n secure-app &>/dev/null; then
    echo "[PASS] NetworkPolicy allow-from-namespaces exists in secure-app"
else
    echo "[FAIL] NetworkPolicy allow-from-namespaces not found in secure-app"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
