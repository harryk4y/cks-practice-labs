#!/bin/bash
FAILED=0

echo "[*] Verifying Q107 (Mock) — ETCD Encryption"
echo ""

ENC_CONFIG="/etc/kubernetes/enc/enc.yaml"
if [ -f "$ENC_CONFIG" ]; then
    echo "[PASS] Encryption config exists"
    if grep -q "aescbc" "$ENC_CONFIG"; then
        echo "[PASS] aescbc provider configured"
    else
        echo "[FAIL] aescbc provider not found"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access $ENC_CONFIG from workspace pod"
fi

if kubectl get secret enc-test -n dev &>/dev/null; then
    echo "[PASS] Secret enc-test exists in dev namespace"
else
    echo "[FAIL] Secret enc-test not found in dev namespace"
    FAILED=1
fi

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
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
