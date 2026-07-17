#!/bin/bash
kubectl delete namespace prod --ignore-not-found
kubectl delete namespace billing --ignore-not-found
rm -rf /var/work/tests/artifacts/13/
echo "[✓] Q10 cleaned up"
