#!/bin/bash
FAILED=0

echo "[*] Verifying Q19 — Cilium Network Policy with Mutual Auth"
echo ""

# Check CiliumNetworkPolicy exists
if kubectl get ciliumnetworkpolicy cnp-myapp-mutual-auth -n myapp &>/dev/null; then
    echo "[PASS] CiliumNetworkPolicy cnp-myapp-mutual-auth exists in myapp"
else
    echo "[FAIL] CiliumNetworkPolicy cnp-myapp-mutual-auth not found in myapp"
    FAILED=1
fi

# Check for authentication mode
AUTH_MODE=$(kubectl get ciliumnetworkpolicy cnp-myapp-mutual-auth -n myapp -o jsonpath='{.spec.ingress[0].authentication.mode}' 2>/dev/null)
if [ "$AUTH_MODE" = "required" ]; then
    echo "[PASS] Mutual authentication mode is 'required'"
else
    echo "[FAIL] Authentication mode is '$AUTH_MODE', expected 'required'"
    FAILED=1
fi

# Check endpoint selector
SELECTOR=$(kubectl get ciliumnetworkpolicy cnp-myapp-mutual-auth -n myapp -o jsonpath='{.spec.endpointSelector.matchLabels.app}' 2>/dev/null)
if [ "$SELECTOR" = "web" ]; then
    echo "[PASS] Endpoint selector targets app=web"
else
    echo "[FAIL] Endpoint selector is '$SELECTOR', expected 'web'"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
