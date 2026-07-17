#!/bin/bash
FAILED=0

echo "[*] Verifying Q109 (Mock) — AppArmor Profile"
echo ""

if kubectl get deployment secured-nginx -n secure-ns &>/dev/null; then
    echo "[PASS] Deployment secured-nginx exists"
else
    echo "[FAIL] Deployment secured-nginx not found in secure-ns"
    FAILED=1
fi

ANNOTATION=$(kubectl get deployment secured-nginx -n secure-ns -o jsonpath='{.spec.template.metadata.annotations.container\.apparmor\.security\.beta\.kubernetes\.io/nginx}' 2>/dev/null)
if [ "$ANNOTATION" = "localhost/restricted-nginx" ]; then
    echo "[PASS] AppArmor annotation correct"
else
    echo "[FAIL] AppArmor annotation is '$ANNOTATION', expected 'localhost/restricted-nginx'"
    FAILED=1
fi

REPLICAS=$(kubectl get deployment secured-nginx -n secure-ns -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "3" ]; then
    echo "[PASS] Replicas is 3"
else
    echo "[FAIL] Replicas is '$REPLICAS', expected 3"
    FAILED=1
fi

if [ -f /var/work/tests/artifacts/mock/109/pods.txt ] && [ -s /var/work/tests/artifacts/mock/109/pods.txt ]; then
    echo "[PASS] Pods list file exists"
else
    echo "[FAIL] /var/work/tests/artifacts/mock/109/pods.txt not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
