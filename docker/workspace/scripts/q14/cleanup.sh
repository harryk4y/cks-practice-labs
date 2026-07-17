#!/bin/bash
kubectl delete namespace prod-stack-1 --ignore-not-found
kubectl delete namespace prod-db --ignore-not-found
echo "[✓] Q14 cleaned up"
