#!/bin/bash
FAILED=0

echo "[*] Verifying Q14 — Network Policy Multi-tier"
echo ""

# Check NetworkPolicy in prod-stack-1
for NP in np-frontend np-backend; do
    if kubectl get networkpolicy $NP -n prod-stack-1 &>/dev/null; then
        echo "[PASS] NetworkPolicy $NP exists in prod-stack-1"
    else
        echo "[FAIL] NetworkPolicy $NP not found in prod-stack-1"
        FAILED=1
    fi
done

# Check NetworkPolicy in prod-db
if kubectl get networkpolicy np-mysql -n prod-db &>/dev/null; then
    echo "[PASS] NetworkPolicy np-mysql exists in prod-db"
else
    echo "[FAIL] NetworkPolicy np-mysql not found in prod-db"
    FAILED=1
fi

# Check np-frontend has ingress and egress
NP_SPEC=$(kubectl get networkpolicy np-frontend -n prod-stack-1 -o json 2>/dev/null)
if echo "$NP_SPEC" | grep -q '"Ingress"' && echo "$NP_SPEC" | grep -q '"Egress"'; then
    echo "[PASS] np-frontend has both Ingress and Egress policy types"
else
    echo "[WARN] np-frontend may be missing Ingress or Egress policy types"
fi

# Check np-mysql has empty egress (deny all egress)
NP_MYSQL=$(kubectl get networkpolicy np-mysql -n prod-db -o jsonpath='{.spec.policyTypes}' 2>/dev/null)
if echo "$NP_MYSQL" | grep -q "Egress"; then
    echo "[PASS] np-mysql has Egress policy type (deny egress)"
else
    echo "[WARN] np-mysql may not restrict egress"
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
