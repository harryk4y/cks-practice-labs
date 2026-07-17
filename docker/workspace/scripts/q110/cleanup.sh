#!/bin/bash
kubectl delete namespace hardened --ignore-not-found
echo "[✓] Q110 cleaned up"
