#!/bin/bash
FAILED=0

if [ -f /var/work/tests/artifacts/1/contexts ]; then
    LINES=$(wc -l < /var/work/tests/artifacts/1/contexts)
    if [ "$LINES" -gt 0 ]; then
        echo "[PASS] contexts file exists with $LINES entries"
    else
        echo "[FAIL] contexts file is empty"
        FAILED=1
    fi
else
    echo "[FAIL] /var/work/tests/artifacts/1/contexts not found"
    FAILED=1
fi

if [ -f /var/work/tests/artifacts/1/cert ]; then
    if grep -q "BEGIN CERTIFICATE" /var/work/tests/artifacts/1/cert 2>/dev/null; then
        echo "[PASS] cert file contains a valid certificate"
    else
        echo "[FAIL] cert file does not contain a valid certificate"
        FAILED=1
    fi
else
    echo "[FAIL] /var/work/tests/artifacts/1/cert not found"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
