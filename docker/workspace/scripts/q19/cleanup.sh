#!/bin/bash
kubectl delete ciliumnetworkpolicy cnp-myapp-mutual-auth -n myapp --ignore-not-found 2>/dev/null
kubectl delete namespace myapp --ignore-not-found
kubectl delete namespace ingress-nginx --ignore-not-found
echo "[✓] Q19 cleaned up"
