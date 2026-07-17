#!/bin/bash
FAILED=0

echo "[*] Verifying Q105 (Mock) — Secrets Management"
echo ""

# Check app password file
if [ -f /var/work/tests/artifacts/mock/105/app-password.txt ]; then
    CONTENT=$(cat /var/work/tests/artifacts/mock/105/app-password.txt)
    if [ "$CONTENT" = "SuperS3cret!" ]; then
        echo "[PASS] App password correctly decoded"
    else
        echo "[FAIL] App password is '$CONTENT', expected 'SuperS3cret!'"
        FAILED=1
    fi
else
    echo "[FAIL] /var/work/tests/artifacts/mock/105/app-password.txt not found"
    FAILED=1
fi

# Check db host file
if [ -f /var/work/tests/artifacts/mock/105/db-host.txt ]; then
    CONTENT=$(cat /var/work/tests/artifacts/mock/105/db-host.txt)
    if [ "$CONTENT" = "db.internal" ]; then
        echo "[PASS] DB host correctly decoded"
    else
        echo "[FAIL] DB host is '$CONTENT', expected 'db.internal'"
        FAILED=1
    fi
else
    echo "[FAIL] /var/work/tests/artifacts/mock/105/db-host.txt not found"
    FAILED=1
fi

# Check combined-creds secret
if kubectl get secret combined-creds -n team-alpha &>/dev/null; then
    APP_USER=$(kubectl get secret combined-creds -n team-alpha -o jsonpath='{.data.app-user}' | base64 -d 2>/dev/null)
    DB_CONN=$(kubectl get secret combined-creds -n team-alpha -o jsonpath='{.data.db-connection}' | base64 -d 2>/dev/null)
    if [ "$APP_USER" = "admin" ]; then
        echo "[PASS] combined-creds app-user is correct"
    else
        echo "[FAIL] combined-creds app-user is '$APP_USER', expected 'admin'"
        FAILED=1
    fi
    if [ "$DB_CONN" = "db.internal:5432" ]; then
        echo "[PASS] combined-creds db-connection is correct"
    else
        echo "[FAIL] combined-creds db-connection is '$DB_CONN', expected 'db.internal:5432'"
        FAILED=1
    fi
else
    echo "[FAIL] Secret 'combined-creds' not found in team-alpha"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
