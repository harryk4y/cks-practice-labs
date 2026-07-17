#!/bin/bash
kubectl delete pod test-latest --ignore-not-found
echo "[*] Q17 — Image Policy Webhook"
echo "To revert: Remove ImagePolicyWebhook from --enable-admission-plugins"
echo "            Remove --admission-control-config-file from apiserver"
echo "[✓] Q17 cleaned up (manual revert needed on node)"
