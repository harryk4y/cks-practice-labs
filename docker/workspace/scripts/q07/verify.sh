#!/bin/bash
FAILED=0

echo "[*] Verifying Q07 — AppArmor Profile"
echo ""

# Check deployment exists
if kubectl get deployment apparmor-deploy -n apparmor &>/dev/null; then
    echo "[PASS] Deployment apparmor-deploy exists in namespace apparmor"
else
    echo "[FAIL] Deployment apparmor-deploy not found in namespace apparmor"
    FAILED=1
fi

# Check AppArmor annotation
ANNOTATION=$(kubectl get deployment apparmor-deploy -n apparmor -o jsonpath='{.spec.template.metadata.annotations.container\.apparmor\.security\.beta\.kubernetes\.io/secure}' 2>/dev/null)
if [ "$ANNOTATION" = "localhost/very-secure" ]; then
    echo "[PASS] AppArmor annotation is correct"
else
    echo "[FAIL] AppArmor annotation is '$ANNOTATION', expected 'localhost/very-secure'"
    FAILED=1
fi

# Check replicas
REPLICAS=$(kubectl get deployment apparmor-deploy -n apparmor -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "2" ]; then
    echo "[PASS] Replicas is 2"
else
    echo "[FAIL] Replicas is '$REPLICAS', expected 2"
    FAILED=1
fi

# Check logs file
if [ -f /var/work/tests/artifacts/9/logs.txt ] && [ -s /var/work/tests/artifacts/9/logs.txt ]; then
    echo "[PASS] Logs file exists and is not empty"
else
    echo "[FAIL] /var/work/tests/artifacts/9/logs.txt not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
