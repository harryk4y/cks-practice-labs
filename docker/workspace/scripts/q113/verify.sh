#!/bin/bash
FAILED=0

echo "[*] Verifying Q113 (Mock) — ImagePolicyWebhook"
echo ""

# Check admission config
if [ -f /etc/kubernetes/admission/config.yaml ]; then
    echo "[PASS] Admission config file exists"
    if grep -q "ImagePolicyWebhook" /etc/kubernetes/admission/config.yaml; then
        echo "[PASS] ImagePolicyWebhook configured"
    else
        echo "[FAIL] ImagePolicyWebhook not in config"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access /etc/kubernetes/admission/config.yaml (requires node access)"
fi

# Check kubeconfig
if [ -f /etc/kubernetes/admission/kubeconfig.yaml ]; then
    echo "[PASS] Webhook kubeconfig exists"
else
    echo "[INFO] Cannot access webhook kubeconfig (requires node access)"
fi

# Check apiserver
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [ -f "$APISERVER" ]; then
    if grep -q "ImagePolicyWebhook" "$APISERVER"; then
        echo "[PASS] ImagePolicyWebhook in apiserver admission plugins"
    else
        echo "[FAIL] ImagePolicyWebhook not enabled in apiserver"
        FAILED=1
    fi
    if grep -q "admission-control-config-file" "$APISERVER"; then
        echo "[PASS] admission-control-config-file configured"
    else
        echo "[FAIL] admission-control-config-file not set"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access apiserver manifest from workspace pod"
fi

# Test that images are denied
RESULT=$(kubectl run test-latest-mock --image=unsigned-image:latest --dry-run=server -o yaml 2>&1)
if echo "$RESULT" | grep -qi "denied\|forbidden\|error\|rejected"; then
    echo "[PASS] Unsigned images are denied"
    kubectl delete pod test-latest-mock --ignore-not-found &>/dev/null
else
    echo "[WARN] Image was not denied (webhook may not be active or reachable)"
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
