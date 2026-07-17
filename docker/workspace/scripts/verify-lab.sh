#!/bin/bash
# Generic lab verification script
# Usage: verify-lab <lab_number>

LAB_NUM="${1:-01}"
LAB_NUM=$(printf "%02d" "$LAB_NUM" 2>/dev/null || echo "$LAB_NUM")
LAB_DIR="/opt/labs/q${LAB_NUM}"

echo "============================================"
echo "  Verifying Q${LAB_NUM}..."
echo "============================================"
echo ""

if [ -f "${LAB_DIR}/verify.sh" ]; then
    bash "${LAB_DIR}/verify.sh"
    EXIT_CODE=$?
    echo ""
    if [ $EXIT_CODE -eq 0 ]; then
        echo "╔══════════════════════════════════╗"
        echo "║          ✓  ALL PASSED           ║"
        echo "╚══════════════════════════════════╝"
    else
        echo "╔══════════════════════════════════╗"
        echo "║         ✗  SOME FAILED           ║"
        echo "╚══════════════════════════════════╝"
    fi
    exit $EXIT_CODE
else
    echo "[!] No verify script found for Q${LAB_NUM}"
    exit 1
fi
