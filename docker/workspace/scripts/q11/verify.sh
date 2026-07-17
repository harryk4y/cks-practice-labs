#!/bin/bash
FAILED=0

echo "[*] Verifying Q11 — Fix Dockerfile"
echo ""

DOCKERFILE="/var/work/14/Dockerfile"

if [ ! -f "$DOCKERFILE" ]; then
    echo "[FAIL] Dockerfile not found at $DOCKERFILE"
    exit 1
fi

# Check FROM
FROM_LINE=$(grep -i "^FROM" "$DOCKERFILE" | head -1)
if echo "$FROM_LINE" | grep -q "ubuntu:20.04"; then
    echo "[PASS] FROM uses ubuntu:20.04"
else
    echo "[FAIL] FROM is '$FROM_LINE', expected ubuntu:20.04"
    FAILED=1
fi

# Check USER is not root
USER_LINE=$(grep -i "^USER" "$DOCKERFILE" | tail -1)
if echo "$USER_LINE" | grep -qi "root"; then
    echo "[FAIL] USER is still root"
    FAILED=1
elif echo "$USER_LINE" | grep -qi "myuser"; then
    echo "[PASS] USER is myuser"
else
    echo "[FAIL] USER is '$USER_LINE', expected 'myuser'"
    FAILED=1
fi

# Check if image was built
if command -v podman &>/dev/null; then
    if podman images | grep -q "my-secure-app"; then
        echo "[PASS] Image 'my-secure-app' exists"
    else
        echo "[FAIL] Image 'my-secure-app' not found (run: podman build -t my-secure-app /var/work/14/)"
        FAILED=1
    fi
else
    echo "[INFO] podman not available, skipping image check"
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
