#!/bin/bash
FAILED=0

echo "[*] Verifying Q21 — Docker Security Configuration"
echo ""
echo "[INFO] This requires node access to verify."
echo "[INFO] Run these checks on the worker node:"
echo ""

# Try to check if we have access
if command -v docker &>/dev/null; then
    # Check docker socket permissions
    PERMS=$(stat -c "%a" /var/run/docker.sock 2>/dev/null)
    if [ "$PERMS" = "660" ]; then
        echo "[PASS] Docker socket permissions are 660"
    else
        echo "[FAIL] Docker socket permissions are $PERMS, expected 660"
        FAILED=1
    fi

    # Check if deployer is in docker group
    if id deployer &>/dev/null; then
        if id deployer 2>/dev/null | grep -q "docker"; then
            echo "[FAIL] User 'deployer' is still in docker group"
            FAILED=1
        else
            echo "[PASS] User 'deployer' is NOT in docker group"
        fi
    else
        echo "[INFO] User 'deployer' does not exist on this system"
    fi
else
    echo "[INFO] Docker not available in workspace pod"
    echo "[INFO] Verification must be done on the node directly"
    echo ""
    echo "  Run on node:"
    echo "    stat -c '%a' /var/run/docker.sock  → should be 660"
    echo "    id deployer | grep docker          → should be empty"
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
