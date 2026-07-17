#!/bin/bash
# Generic lab setup script
# Usage: setup-lab.sh <lab_number>

LAB_NUM="${1:-01}"
# Zero-pad single digits
LAB_NUM=$(printf "%02d" "$LAB_NUM" 2>/dev/null || echo "$LAB_NUM")
LAB_DIR="/opt/labs/q${LAB_NUM}"

echo "============================================"
echo "  CKS Practice Lab - Question ${LAB_NUM}"
echo "============================================"
echo ""

if [ -f "${LAB_DIR}/setup.sh" ]; then
    echo "[*] Running setup for Q${LAB_NUM}..."
    bash "${LAB_DIR}/setup.sh"
    echo ""
    echo "[✓] Lab environment ready!"
else
    echo "[!] No setup script found for Q${LAB_NUM}"
    echo "    Expected: ${LAB_DIR}/setup.sh"
fi

echo ""
echo "Commands available:"
echo "  verify-lab ${LAB_NUM}  - Check your solution"
echo "  cleanup-lab ${LAB_NUM} - Tear down the environment"
echo "  show-hint ${LAB_NUM}   - Get a hint"
echo ""
