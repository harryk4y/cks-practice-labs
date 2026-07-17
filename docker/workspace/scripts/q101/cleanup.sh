#!/bin/bash
kubectl delete namespace team-gold --ignore-not-found
kubectl delete runtimeclass gvisor --ignore-not-found
rm -rf /var/work/tests/artifacts/mock/101/
echo "[✓] Q101 cleaned up"
