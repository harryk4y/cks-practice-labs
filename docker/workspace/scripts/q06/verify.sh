#!/bin/bash
FAILED=0

echo "[*] Verifying Q06 — OPA Gatekeeper Blacklist Images"
echo ""

# Check ConstraintTemplate exists
if kubectl get constrainttemplate k8strustedimages &>/dev/null; then
    echo "[PASS] ConstraintTemplate k8strustedimages exists"
else
    echo "[FAIL] ConstraintTemplate k8strustedimages not found"
    FAILED=1
fi

# Check Constraint exists
if kubectl get k8strustedimages trusted-images &>/dev/null; then
    echo "[PASS] Constraint trusted-images exists"
else
    echo "[FAIL] Constraint trusted-images not found"
    FAILED=1
fi

# Test that very-bad-registry.com is blocked
RESULT=$(kubectl run test-bad-image --image=very-bad-registry.com/evil:latest --dry-run=server -o yaml 2>&1)
if echo "$RESULT" | grep -qi "denied\|error\|forbidden\|violated"; then
    echo "[PASS] Images from very-bad-registry.com are blocked"
else
    echo "[FAIL] Images from very-bad-registry.com are NOT blocked"
    FAILED=1
fi

# Clean up test pod if accidentally created
kubectl delete pod test-bad-image --ignore-not-found &>/dev/null

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
