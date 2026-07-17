#!/bin/bash
kubectl delete namespace external --ignore-not-found
kubectl delete namespace finance --ignore-not-found
echo "[✓] Q18 cleaned up"
echo "Note: Cilium uninstall: helm uninstall cilium -n kube-system"
