#!/bin/bash
kubectl delete namespace team-red --ignore-not-found
rm -rf /var/work/tests/artifacts/4/
echo "[✓] Q04 cleaned up"
