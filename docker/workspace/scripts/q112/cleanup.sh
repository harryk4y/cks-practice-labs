#!/bin/bash
kubectl delete namespace suspicious --ignore-not-found
rm -rf /var/work/tests/artifacts/mock/112/
echo "[✓] Q112 cleaned up"
