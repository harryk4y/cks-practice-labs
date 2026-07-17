#!/bin/bash
FAILED=0

echo "[*] Verifying Q111 (Mock) — RBAC Roles and Bindings"
echo ""

# Check Role pod-reader
if kubectl get role pod-reader -n dev-team &>/dev/null; then
    echo "[PASS] Role pod-reader exists"
else
    echo "[FAIL] Role pod-reader not found in dev-team"
    FAILED=1
fi

# Check Role deployment-manager
if kubectl get role deployment-manager -n dev-team &>/dev/null; then
    echo "[PASS] Role deployment-manager exists"
else
    echo "[FAIL] Role deployment-manager not found in dev-team"
    FAILED=1
fi

# Check RoleBinding developer-pod-reader
if kubectl get rolebinding developer-pod-reader -n dev-team &>/dev/null; then
    echo "[PASS] RoleBinding developer-pod-reader exists"
else
    echo "[FAIL] RoleBinding developer-pod-reader not found"
    FAILED=1
fi

# Check RoleBinding deployer-deployment-manager
if kubectl get rolebinding deployer-deployment-manager -n dev-team &>/dev/null; then
    echo "[PASS] RoleBinding deployer-deployment-manager exists"
else
    echo "[FAIL] RoleBinding deployer-deployment-manager not found"
    FAILED=1
fi

# Verify access with can-i
CAN_GET_PODS=$(kubectl auth can-i get pods --as=system:serviceaccount:dev-team:developer -n dev-team 2>/dev/null)
if [ "$CAN_GET_PODS" = "yes" ]; then
    echo "[PASS] developer can get pods"
else
    echo "[FAIL] developer cannot get pods"
    FAILED=1
fi

CAN_CREATE_DEPLOY=$(kubectl auth can-i create deployments --as=system:serviceaccount:dev-team:deployer -n dev-team 2>/dev/null)
if [ "$CAN_CREATE_DEPLOY" = "yes" ]; then
    echo "[PASS] deployer can create deployments"
else
    echo "[FAIL] deployer cannot create deployments"
    FAILED=1
fi

# Verify developer CANNOT create deployments
CAN_DEV_CREATE=$(kubectl auth can-i create deployments --as=system:serviceaccount:dev-team:developer -n dev-team 2>/dev/null)
if [ "$CAN_DEV_CREATE" = "no" ]; then
    echo "[PASS] developer cannot create deployments (least privilege)"
else
    echo "[WARN] developer can create deployments (may have excessive permissions)"
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
