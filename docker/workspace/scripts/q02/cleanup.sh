#!/bin/bash
kubectl delete pod nginx-target -n monitoring --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found
rm -rf /var/work/tests/artifacts/12/
echo "[✓] Q02 cleaned up"
