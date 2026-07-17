#!/bin/bash
echo "[*] Setting up Q01 — kubectl Contexts"
echo ""
mkdir -p /var/work/tests/artifacts/1/
echo "[✓] Artifacts directory created"
echo ""
echo "Task: Write all context names to /var/work/tests/artifacts/1/contexts"
echo "Task: Save decoded cert of user cluster9-admin to /var/work/tests/artifacts/1/cert"
echo ""
echo "Hints:"
echo "  kubectl config get-contexts -o name"
echo "  kubectl config view --raw"
