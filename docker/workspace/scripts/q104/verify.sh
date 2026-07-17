#!/bin/bash
FAILED=0

echo "[*] Verifying Q104 (Mock) — CIS Benchmark"
echo ""

APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
CM="/etc/kubernetes/manifests/kube-controller-manager.yaml"
SCHED="/etc/kubernetes/manifests/kube-scheduler.yaml"

if [ -f "$APISERVER" ]; then
    if grep -q "profiling=false" "$APISERVER"; then
        echo "[PASS] kube-apiserver has --profiling=false"
    else
        echo "[FAIL] kube-apiserver missing --profiling=false"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access apiserver manifest (requires node access)"
fi

if [ -f "$CM" ]; then
    if grep -q "profiling=false" "$CM"; then
        echo "[PASS] controller-manager has --profiling=false"
    else
        echo "[FAIL] controller-manager missing --profiling=false"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access controller-manager manifest"
fi

if [ -f "$SCHED" ]; then
    if grep -q "profiling=false" "$SCHED"; then
        echo "[PASS] scheduler has --profiling=false"
    else
        echo "[FAIL] scheduler missing --profiling=false"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access scheduler manifest"
fi

# Check kubelet config
KUBELET="/var/lib/kubelet/config.yaml"
if [ -f "$KUBELET" ]; then
    if grep -q "protectKernelDefaults: true" "$KUBELET"; then
        echo "[PASS] kubelet has protectKernelDefaults: true"
    else
        echo "[FAIL] kubelet missing protectKernelDefaults: true"
        FAILED=1
    fi
else
    echo "[INFO] Cannot access kubelet config (requires node access)"
fi

echo ""
if [ $FAILED -eq 0 ]; then echo "PASS"; exit 0; else echo "FAIL"; exit 1; fi
