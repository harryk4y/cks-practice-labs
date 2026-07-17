#!/bin/bash
FAILED=0

echo "[*] Verifying Q110 (Mock) — Deployment Security Context"
echo ""

# Check deployment exists
if ! kubectl get deployment web-app -n hardened &>/dev/null; then
    echo "[FAIL] Deployment web-app not found in hardened namespace"
    exit 1
fi

# Check runAsNonRoot
RUN_AS_NON_ROOT=$(kubectl get deployment web-app -n hardened -o jsonpath='{.spec.template.spec.securityContext.runAsNonRoot}' 2>/dev/null)
if [ "$RUN_AS_NON_ROOT" = "true" ]; then
    echo "[PASS] runAsNonRoot is true"
else
    echo "[FAIL] runAsNonRoot is '$RUN_AS_NON_ROOT', expected true"
    FAILED=1
fi

# Check allowPrivilegeEscalation
APE=$(kubectl get deployment web-app -n hardened -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
if [ "$APE" = "false" ]; then
    echo "[PASS] allowPrivilegeEscalation is false"
else
    echo "[FAIL] allowPrivilegeEscalation is '$APE', expected false"
    FAILED=1
fi

# Check readOnlyRootFilesystem
RORFS=$(kubectl get deployment web-app -n hardened -o jsonpath='{.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)
if [ "$RORFS" = "true" ]; then
    echo "[PASS] readOnlyRootFilesystem is true"
else
    echo "[FAIL] readOnlyRootFilesystem is '$RORFS', expected true"
    FAILED=1
fi

# Check capabilities drop ALL
DROP=$(kubectl get deployment web-app -n hardened -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.drop}' 2>/dev/null)
if echo "$DROP" | grep -qi "ALL"; then
    echo "[PASS] Capabilities drop ALL"
else
    echo "[FAIL] Capabilities drop is '$DROP', expected ALL"
    FAILED=1
fi

# Check automountServiceAccountToken
AUTOMOUNT=$(kubectl get deployment web-app -n hardened -o jsonpath='{.spec.template.spec.automountServiceAccountToken}' 2>/dev/null)
if [ "$AUTOMOUNT" = "false" ]; then
    echo "[PASS] automountServiceAccountToken is false"
else
    echo "[FAIL] automountServiceAccountToken is '$AUTOMOUNT', expected false"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
