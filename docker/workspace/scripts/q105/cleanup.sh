#!/bin/bash
kubectl delete namespace team-alpha --ignore-not-found
rm -rf /var/work/tests/artifacts/mock/105/
echo "[✓] Q105 cleaned up"
