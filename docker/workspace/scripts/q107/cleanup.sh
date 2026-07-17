#!/bin/bash
kubectl delete secret enc-test -n dev --ignore-not-found
kubectl delete namespace dev --ignore-not-found
echo "[✓] Q107 cleaned up"
echo "Note: Remove --encryption-provider-config from apiserver and /etc/kubernetes/enc/ on node"
