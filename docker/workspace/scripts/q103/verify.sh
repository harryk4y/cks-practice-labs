#!/bin/bash
FAILED=0

echo "[*] Verifying Q103 (Mock) — Audit Logging"
echo ""

if [ -f /etc/kubernetes/audit/policy.yaml ]; then
    echo "[PASS] Audit policy file exists"
else
    echo "[FAIL] /etc/kubernetes/audit/policy.yaml not found"
    FAILED=1
fi

APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [ -f "$APISERVER" ]; then
    if grep -q "audit-policy-file" "$APISERVER"; then
        echo "[PASS] kube-apiserver has --audit-policy-file"
    else
        echo "[FAIL] kube-apiserver missing --audit-policy-file"
        FAILED=1
    fi
    if grep -q "audit-log-path" "$APISERVER"; then
        echo "[PASS] kube-apiserver has --audit-log-path"
    else
        echo "[FAIL] kube-apiserver missing --audit-log-path"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access apiserver manifest from workspace pod"
fi

if [ -f /var/work/tests/artifacts/mock/103/audit.json ] && [ -s /var/work/tests/artifacts/mock/103/audit.json ]; then
    echo "[PASS] Audit entries file exists"
else
    echo "[FAIL] /var/work/tests/artifacts/mock/103/audit.json not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
