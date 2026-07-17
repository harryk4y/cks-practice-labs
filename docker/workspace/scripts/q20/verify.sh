#!/bin/bash
FAILED=0

echo "[*] Verifying Q20 — Detect Unauthorized Memory Access (Falco)"
echo ""

# Check deployment is scaled to 0
REPLICAS=$(kubectl get deployment memory-reader -n monitoring -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "0" ]; then
    echo "[PASS] Deployment memory-reader scaled to 0 replicas"
else
    echo "[FAIL] Deployment memory-reader has $REPLICAS replicas, expected 0"
    FAILED=1
fi

# Check Falco alert file
if [ -f /var/work/tests/artifacts/20/falco-alert.txt ] && [ -s /var/work/tests/artifacts/20/falco-alert.txt ]; then
    echo "[PASS] Falco alert file exists and is not empty"
else
    echo "[FAIL] /var/work/tests/artifacts/20/falco-alert.txt not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
