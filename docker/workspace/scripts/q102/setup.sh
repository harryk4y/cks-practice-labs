#!/bin/bash
echo "[*] Setting up Q102 (Mock) — Image Scanning + SBOM Generation"
echo ""

mkdir -p /var/work/tests/artifacts/mock/102/

echo "Task:"
echo "  Scan container images for vulnerabilities and generate an SBOM."
echo ""
echo "  1. Use trivy to scan 'nginx:1.21' for HIGH and CRITICAL vulnerabilities:"
echo "     trivy image --severity HIGH,CRITICAL nginx:1.21"
echo "     Save output to: /var/work/tests/artifacts/mock/102/trivy-scan.txt"
echo ""
echo "  2. Generate an SBOM (Software Bill of Materials) in SPDX format:"
echo "     trivy image --format spdx-json nginx:1.21 > /var/work/tests/artifacts/mock/102/sbom.json"
echo "     OR: syft nginx:1.21 -o spdx-json > /var/work/tests/artifacts/mock/102/sbom.json"
echo ""
echo "  3. Count total HIGH + CRITICAL CVEs and save to:"
echo "     /var/work/tests/artifacts/mock/102/cve-count.txt"
echo ""
echo "Weight: 3%"
