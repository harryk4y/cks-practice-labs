#!/bin/bash
kubectl delete namespace secure-ns --ignore-not-found
rm -rf /var/work/tests/artifacts/mock/109/
echo "[✓] Q109 cleaned up"
