#!/bin/bash
kubectl delete namespace team-purple --ignore-not-found
kubectl delete runtimeclass gvisor --ignore-not-found
rm -rf /var/work/tests/artifacts/10/
echo "[✓] Q08 cleaned up"
