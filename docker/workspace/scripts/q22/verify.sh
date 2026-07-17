#!/bin/bash
FAILED=0

echo "[*] Verifying Q22 — Istio mTLS Policy"
echo ""

# Check PeerAuthentication exists
if kubectl get peerauthentication strict-mtls -n market &>/dev/null; then
    echo "[PASS] PeerAuthentication 'strict-mtls' exists in market namespace"
else
    echo "[FAIL] PeerAuthentication 'strict-mtls' not found in market namespace"
    FAILED=1
fi

# Check mode is STRICT
MODE=$(kubectl get peerauthentication strict-mtls -n market -o jsonpath='{.spec.mtls.mode}' 2>/dev/null)
if [ "$MODE" = "STRICT" ]; then
    echo "[PASS] mTLS mode is STRICT"
else
    echo "[FAIL] mTLS mode is '$MODE', expected 'STRICT'"
    FAILED=1
fi

# Check namespace has Istio injection label
INJECTION=$(kubectl get ns market -o jsonpath='{.metadata.labels.istio-injection}' 2>/dev/null)
if [ "$INJECTION" = "enabled" ]; then
    echo "[PASS] Namespace 'market' has istio-injection=enabled"
else
    echo "[WARN] Namespace 'market' istio-injection label is '$INJECTION'"
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
