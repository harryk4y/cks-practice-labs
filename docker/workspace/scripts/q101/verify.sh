#!/bin/bash
FAILED=0

echo "[*] Verifying Q101 (Mock) — Container Runtime Sandbox gVisor"
echo ""

HANDLER=$(kubectl get runtimeclass gvisor -o jsonpath='{.handler}' 2>/dev/null)
if [ "$HANDLER" = "runsc" ]; then
    echo "[PASS] RuntimeClass gvisor exists with handler 'runsc'"
else
    echo "[FAIL] RuntimeClass gvisor not found or handler is '$HANDLER'"
    FAILED=1
fi

for DEPLOY in app-gold cache-gold; do
    RC=$(kubectl get deployment $DEPLOY -n team-gold -o jsonpath='{.spec.template.spec.runtimeClassName}' 2>/dev/null)
    if [ "$RC" = "gvisor" ]; then
        echo "[PASS] Deployment $DEPLOY uses gvisor"
    else
        echo "[FAIL] Deployment $DEPLOY runtimeClassName is '$RC', expected 'gvisor'"
        FAILED=1
    fi
done

if [ -f /var/work/tests/artifacts/mock/101/dmesg.txt ] && [ -s /var/work/tests/artifacts/mock/101/dmesg.txt ]; then
    echo "[PASS] dmesg output file exists"
else
    echo "[FAIL] /var/work/tests/artifacts/mock/101/dmesg.txt not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
