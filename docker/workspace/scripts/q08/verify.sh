#!/bin/bash
FAILED=0

echo "[*] Verifying Q08 — Container Runtime Sandbox gVisor"
echo ""

# Check RuntimeClass exists
HANDLER=$(kubectl get runtimeclass gvisor -o jsonpath='{.handler}' 2>/dev/null)
if [ "$HANDLER" = "runsc" ]; then
    echo "[PASS] RuntimeClass gvisor exists with handler 'runsc'"
else
    echo "[FAIL] RuntimeClass gvisor not found or handler is '$HANDLER', expected 'runsc'"
    FAILED=1
fi

# Check deployments use gvisor runtime
for DEPLOY in web-purple api-purple; do
    RC=$(kubectl get deployment $DEPLOY -n team-purple -o jsonpath='{.spec.template.spec.runtimeClassName}' 2>/dev/null)
    if [ "$RC" = "gvisor" ]; then
        echo "[PASS] Deployment $DEPLOY uses runtimeClassName 'gvisor'"
    else
        echo "[FAIL] Deployment $DEPLOY runtimeClassName is '$RC', expected 'gvisor'"
        FAILED=1
    fi
done

# Check dmesg file
if [ -f /var/work/tests/artifacts/10/dmesg.txt ] && [ -s /var/work/tests/artifacts/10/dmesg.txt ]; then
    echo "[PASS] dmesg output file exists and is not empty"
else
    echo "[FAIL] /var/work/tests/artifacts/10/dmesg.txt not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
