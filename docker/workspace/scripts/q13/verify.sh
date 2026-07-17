#!/bin/bash
FAILED=0

echo "[*] Verifying Q13 — Image Vulnerability Scanning"
echo ""

REPORT="/var/work/tests/artifacts/15/cve-report.txt"

if [ -f "$REPORT" ] && [ -s "$REPORT" ]; then
    echo "[PASS] CVE report file exists and is not empty"
    
    # Check for expected CVEs in report
    for CVE in CVE-2021-28831 CVE-2021-3711 CVE-2022-0778; do
        if grep -q "$CVE" "$REPORT"; then
            echo "[PASS] $CVE documented in report"
        else
            echo "[FAIL] $CVE not found in report"
            FAILED=1
        fi
    done
else
    echo "[FAIL] $REPORT not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
