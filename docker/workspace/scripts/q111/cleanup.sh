#!/bin/bash
kubectl delete rolebinding developer-pod-reader -n dev-team --ignore-not-found
kubectl delete rolebinding deployer-deployment-manager -n dev-team --ignore-not-found
kubectl delete role pod-reader -n dev-team --ignore-not-found
kubectl delete role deployment-manager -n dev-team --ignore-not-found
kubectl delete namespace dev-team --ignore-not-found
echo "[✓] Q111 cleaned up"
