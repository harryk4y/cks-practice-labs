#!/bin/bash
kubectl delete namespace apparmor --ignore-not-found
kubectl label nodes --all security- 2>/dev/null
rm -rf /var/work/tests/artifacts/9/
echo "[✓] Q07 cleaned up"
