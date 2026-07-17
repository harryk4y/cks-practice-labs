#!/bin/bash
# Generic lab cleanup script
# Usage: cleanup-lab <lab_number>

LAB_NUM="${1:-01}"
LAB_NUM=$(printf "%02d" "$LAB_NUM" 2>/dev/null || echo "$LAB_NUM")
LAB_DIR="/opt/labs/q${LAB_NUM}"

echo "[*] Cleaning up Q${LAB_NUM}..."

if [ -f "${LAB_DIR}/cleanup.sh" ]; then
    bash "${LAB_DIR}/cleanup.sh"
    echo "[✓] Cleanup complete."
else
    echo "[!] No cleanup script found for Q${LAB_NUM}"
fi
