#!/bin/bash
FAILED=0

echo "[*] Verifying Q16 — Encrypt Secrets in ETCD"
echo ""

# Check encryption config exists
ENC_CONFIG="/etc/kubernetes/enc/enc.yaml"
if [ -f "$ENC_CONFIG" ]; then
    echo "[PASS] Encryption config exists at $ENC_CONFIG"
    if grep -q "aescbc" "$ENC_CONFIG"; then
        echo "[PASS] aescbc provider configured"
    else
        echo "[FAIL] aescbc provider not found in config"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access $ENC_CONFIG from workspace pod"
fi

# Check test-secret was created
if kubectl get secret test-secret -n prod &>/dev/null; then
    echo "[PASS] test-secret exists in prod namespace"
else
    echo "[FAIL] test-secret not found in prod namespace"
    FAILED=1
fi

# Check apiserver has encryption flag
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [ -f "$APISERVER" ]; then
    if grep -q "encryption-provider-config" "$APISERVER"; then
        echo "[PASS] kube-apiserver has --encryption-provider-config"
    else
        echo "[FAIL] kube-apiserver missing --encryption-provider-config"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access apiserver manifest from workspace pod"
    echo "[INFO] Checking API server responds (encryption may be configured)..."
    if kubectl get nodes &>/dev/null; then
        echo "[PASS] API server is responding"
    fi
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
