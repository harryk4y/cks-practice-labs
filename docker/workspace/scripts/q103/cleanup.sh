#!/bin/bash
kubectl delete namespace payments --ignore-not-found
kubectl delete namespace internal --ignore-not-found
rm -rf /var/work/tests/artifacts/mock/103/
echo "[✓] Q103 cleaned up"
