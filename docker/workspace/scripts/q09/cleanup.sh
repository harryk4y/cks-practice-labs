#!/bin/bash
kubectl delete namespace team-green --ignore-not-found
rm -rf /var/work/tests/artifacts/11/
echo "[✓] Q09 cleaned up"
