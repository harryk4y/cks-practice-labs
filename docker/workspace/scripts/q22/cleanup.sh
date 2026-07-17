#!/bin/bash
kubectl delete peerauthentication strict-mtls -n market --ignore-not-found 2>/dev/null
kubectl delete namespace market --ignore-not-found
echo "[✓] Q22 cleaned up"
