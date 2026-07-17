#!/bin/bash
kubectl delete deployment memory-reader -n monitoring --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found
rm -rf /var/work/tests/artifacts/20/
echo "[✓] Q20 cleaned up"
