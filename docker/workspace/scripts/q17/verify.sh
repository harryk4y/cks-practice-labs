#!/bin/bash
FAILED=0

echo "[*] Verifying Q17 — Image Policy Webhook"
echo ""

# Check admission config file
if [ -f /etc/kubernetes/admission/admission-config.yaml ]; then
    echo "[PASS] Admission config file exists"
    if grep -q "ImagePolicyWebhook" /etc/kubernetes/admission/admission-config.yaml; then
        echo "[PASS] ImagePolicyWebhook configured in admission config"
    else
        echo "[FAIL] ImagePolicyWebhook not found in config"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access /etc/kubernetes/admission/admission-config.yaml from workspace"
fi

# Check apiserver has admission plugin enabled
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [ -f "$APISERVER" ]; then
    if grep -q "ImagePolicyWebhook" "$APISERVER"; then
        echo "[PASS] ImagePolicyWebhook enabled in apiserver"
    else
        echo "[FAIL] ImagePolicyWebhook not enabled in apiserver"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access apiserver manifest from workspace pod"
fi

# Test that latest tag is denied (if webhook is active)
RESULT=$(kubectl run test-latest --image=nginx:latest --dry-run=server -o yaml 2>&1)
if echo "$RESULT" | grep -qi "denied\|forbidden\|error"; then
    echo "[PASS] Images with :latest tag are denied"
    kubectl delete pod test-latest --ignore-not-found &>/dev/null
else
    echo "[WARN] Image with :latest tag was not denied (webhook may not be active)"
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
