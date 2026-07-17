#!/bin/bash
FAILED=0

LABEL=$(kubectl get ns team-red -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null)
if [ "$LABEL" = "baseline" ]; then
    echo "[PASS] team-red has baseline PSS enforce label"
else
    echo "[FAIL] team-red PSS label is '$LABEL', expected 'baseline'"
    FAILED=1
fi

if [ -f /var/work/tests/artifacts/4/events.log ]; then
    if [ -s /var/work/tests/artifacts/4/events.log ]; then
        echo "[PASS] events.log exists and is not empty"
    else
        echo "[FAIL] events.log is empty"
        FAILED=1
    fi
else
    echo "[FAIL] /var/work/tests/artifacts/4/events.log not found"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
