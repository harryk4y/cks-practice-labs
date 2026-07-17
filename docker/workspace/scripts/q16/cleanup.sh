#!/bin/bash
kubectl delete secret test-secret -n prod --ignore-not-found
kubectl delete namespace stage --ignore-not-found
kubectl delete namespace prod --ignore-not-found
rm -rf /var/work/tests/artifacts/16/
echo "[✓] Q16 cleaned up"
echo "Note: Remove --encryption-provider-config from apiserver and delete /etc/kubernetes/enc/ on node"
