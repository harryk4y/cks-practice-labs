#!/bin/bash
FAILED=0

echo "[*] Verifying Q112 (Mock) — Falco Detection (/etc/shadow read)"
echo ""

# Check deployment is scaled to 0
REPLICAS=$(kubectl get deployment shadow-reader -n suspicious -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "0" ]; then
    echo "[PASS] Deployment shadow-reader scaled to 0"
else
    echo "[FAIL] Deployment shadow-reader has $REPLICAS replicas, expected 0"
    FAILED=1
fi

# Check alert file
if [ -f /var/work/tests/artifacts/mock/112/alert.txt ] && [ -s /var/work/tests/artifacts/mock/112/alert.txt ]; then
    echo "[PASS] Falco alert file exists and is not empty"
else
    echo "[FAIL] /var/work/tests/artifacts/mock/112/alert.txt not found or empty"
    FAILED=1
fi

# Check pod-name file
if [ -f /var/work/tests/artifacts/mock/112/pod-name.txt ] && [ -s /var/work/tests/artifacts/mock/112/pod-name.txt ]; then
    echo "[PASS] Pod name file exists"
else
    echo "[FAIL] /var/work/tests/artifacts/mock/112/pod-name.txt not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
