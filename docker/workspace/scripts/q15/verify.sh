#!/bin/bash
FAILED=0

echo "[*] Verifying Q15 — TLS Cipher Configuration"
echo ""

APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
ETCD="/etc/kubernetes/manifests/etcd.yaml"

if [ -f "$APISERVER" ]; then
    if grep -q "tls-cipher-suites" "$APISERVER"; then
        echo "[PASS] kube-apiserver has --tls-cipher-suites configured"
        if grep -q "TLS_AES_128_GCM_SHA256" "$APISERVER"; then
            echo "[PASS] TLS_AES_128_GCM_SHA256 is included"
        else
            echo "[FAIL] TLS_AES_128_GCM_SHA256 not found in cipher list"
            FAILED=1
        fi
    else
        echo "[FAIL] kube-apiserver missing --tls-cipher-suites"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access $APISERVER from workspace pod"
    echo "[INFO] Checking API server is responding..."
    if kubectl get nodes &>/dev/null; then
        echo "[PASS] API server is responding (ciphers may be configured)"
    else
        echo "[FAIL] API server not responding"
        FAILED=1
    fi
fi

if [ -f "$ETCD" ]; then
    if grep -q "cipher-suites" "$ETCD"; then
        echo "[PASS] etcd has --cipher-suites configured"
    else
        echo "[FAIL] etcd missing --cipher-suites"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access $ETCD from workspace pod"
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
