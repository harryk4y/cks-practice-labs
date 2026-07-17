#!/bin/bash
rm -rf /var/work/14/
podman rmi my-secure-app 2>/dev/null || true
echo "[✓] Q11 cleaned up"
