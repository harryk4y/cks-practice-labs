#!/bin/bash
kubectl delete namespace secure-app --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found
kubectl delete namespace trusted --ignore-not-found
echo "[✓] Q108 cleaned up"
