#!/bin/bash
FAILED=0

SVC_TYPE=$(kubectl get svc kubernetes -o jsonpath='{.spec.type}' 2>/dev/null)
if [ "$SVC_TYPE" = "ClusterIP" ] || [ -z "$SVC_TYPE" ]; then
    echo "[PASS] kubernetes service is ClusterIP"
else
    echo "[FAIL] kubernetes service is $SVC_TYPE, expected ClusterIP"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
