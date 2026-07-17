#!/bin/bash
FAILED=0

echo "[*] Verifying Q09 — Secrets in ETCD"
echo ""

# Check secret exists
if kubectl get secret database-access -n team-green &>/dev/null; then
    echo "[PASS] Secret 'database-access' exists in team-green"
else
    echo "[FAIL] Secret 'database-access' not found in team-green"
    FAILED=1
fi

# Check etcd output file
if [ -f /var/work/tests/artifacts/11/etcd-secret-output.txt ] && [ -s /var/work/tests/artifacts/11/etcd-secret-output.txt ]; then
    echo "[PASS] ETCD output file exists and is not empty"
else
    echo "[FAIL] /var/work/tests/artifacts/11/etcd-secret-output.txt not found or empty"
    FAILED=1
fi

# Check decoded secret file
if [ -f /var/work/tests/artifacts/11/decoded-secret.txt ] && [ -s /var/work/tests/artifacts/11/decoded-secret.txt ]; then
    if grep -q "s3cr3t-p@ss!" /var/work/tests/artifacts/11/decoded-secret.txt 2>/dev/null; then
        echo "[PASS] Decoded secret contains correct password"
    else
        echo "[FAIL] Decoded secret does not contain expected value"
        FAILED=1
    fi
else
    echo "[FAIL] /var/work/tests/artifacts/11/decoded-secret.txt not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
