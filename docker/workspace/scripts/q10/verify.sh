#!/bin/bash
FAILED=0

echo "[*] Verifying Q10 — Enable Audit Logging"
echo ""

# Check audit policy file
if [ -f /etc/kubernetes/audit/policy.yaml ]; then
    echo "[PASS] Audit policy file exists"
    # Check for key rules
    if grep -q "RequestReceived" /etc/kubernetes/audit/policy.yaml; then
        echo "[PASS] Policy references RequestReceived stage"
    else
        echo "[WARN] Policy may not exclude RequestReceived stage"
    fi
else
    echo "[FAIL] /etc/kubernetes/audit/policy.yaml not found"
    FAILED=1
fi

# Check kube-apiserver flags
APISERVER_MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [ -f "$APISERVER_MANIFEST" ]; then
    if grep -q "audit-policy-file" "$APISERVER_MANIFEST"; then
        echo "[PASS] kube-apiserver has --audit-policy-file flag"
    else
        echo "[FAIL] kube-apiserver missing --audit-policy-file flag"
        FAILED=1
    fi
    if grep -q "audit-log-path" "$APISERVER_MANIFEST"; then
        echo "[PASS] kube-apiserver has --audit-log-path flag"
    else
        echo "[FAIL] kube-apiserver missing --audit-log-path flag"
        FAILED=1
    fi
    if grep -q "audit-log-maxsize" "$APISERVER_MANIFEST"; then
        echo "[PASS] kube-apiserver has --audit-log-maxsize flag"
    else
        echo "[FAIL] kube-apiserver missing --audit-log-maxsize flag"
        FAILED=1
    fi
else
    echo "[INFO] Cannot check apiserver manifest from workspace pod (requires node access)"
    echo "[INFO] Checking if audit entries file exists instead..."
fi

# Check audit entries file
if [ -f /var/work/tests/artifacts/13/audit-entries.json ] && [ -s /var/work/tests/artifacts/13/audit-entries.json ]; then
    echo "[PASS] Audit entries file exists and is not empty"
else
    echo "[FAIL] /var/work/tests/artifacts/13/audit-entries.json not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
