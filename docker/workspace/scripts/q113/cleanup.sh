#!/bin/bash
kubectl delete pod test-latest-mock --ignore-not-found
echo "[*] Q113 — ImagePolicyWebhook"
echo "To revert: Remove ImagePolicyWebhook from --enable-admission-plugins on node"
echo "[✓] Q113 cleaned up (manual revert needed on node)"
