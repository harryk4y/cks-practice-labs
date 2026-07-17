#!/bin/bash
kubectl delete k8strustedimages trusted-images --ignore-not-found
kubectl delete constrainttemplate k8strustedimages --ignore-not-found
kubectl delete pod test-bad-image --ignore-not-found
echo "[✓] Q06 cleaned up"
