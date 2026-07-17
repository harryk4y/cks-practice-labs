#!/bin/bash
FAILED=0

if [ -f /var/work/tests/artifacts/12/log ]; then
    LINES=$(wc -l < /var/work/tests/artifacts/12/log)
    if [ "$LINES" -gt 0 ]; then
        echo "[PASS] Log file exists with $LINES lines"
    else
        echo "[FAIL] Log file is empty"
        FAILED=1
    fi
else
    echo "[FAIL] /var/work/tests/artifacts/12/log not found"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
