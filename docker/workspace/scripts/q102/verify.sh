#!/bin/bash
FAILED=0

echo "[*] Verifying Q102 (Mock) — Image Scanning + SBOM Generation"
echo ""

if [ -f /var/work/tests/artifacts/mock/102/trivy-scan.txt ] && [ -s /var/work/tests/artifacts/mock/102/trivy-scan.txt ]; then
    echo "[PASS] Trivy scan output exists"
else
    echo "[FAIL] /var/work/tests/artifacts/mock/102/trivy-scan.txt not found or empty"
    FAILED=1
fi

if [ -f /var/work/tests/artifacts/mock/102/sbom.json ] && [ -s /var/work/tests/artifacts/mock/102/sbom.json ]; then
    if grep -q "spdx\|SPDX\|packages" /var/work/tests/artifacts/mock/102/sbom.json; then
        echo "[PASS] SBOM file exists and appears to be SPDX format"
    else
        echo "[FAIL] SBOM file exists but doesn't appear to be SPDX format"
        FAILED=1
    fi
else
    echo "[FAIL] /var/work/tests/artifacts/mock/102/sbom.json not found or empty"
    FAILED=1
fi

if [ -f /var/work/tests/artifacts/mock/102/cve-count.txt ] && [ -s /var/work/tests/artifacts/mock/102/cve-count.txt ]; then
    echo "[PASS] CVE count file exists"
else
    echo "[FAIL] /var/work/tests/artifacts/mock/102/cve-count.txt not found or empty"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
