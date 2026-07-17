#!/bin/bash
echo "[*] Setting up Q20 — Detect Unauthorized Memory Access (Falco)"
echo ""

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Create a deployment that attempts to access /dev/mem
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-reader
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-reader
  template:
    metadata:
      labels:
        app: memory-reader
    spec:
      containers:
      - name: reader
        image: busybox
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            cat /dev/mem 2>/dev/null || true
            sleep 30
          done
        securityContext:
          privileged: true
EOF

echo "[✓] Deployment 'memory-reader' created in namespace 'monitoring'"
echo ""
echo "Task:"
echo "  A pod in the 'monitoring' namespace is accessing /dev/mem."
echo "  Use Falco to detect this unauthorized behavior."
echo ""
echo "  1. Check Falco logs to identify the offending pod:"
echo "     kubectl logs -l app=falco -n falco | grep '/dev/mem'"
echo "     OR: journalctl -u falco | grep '/dev/mem'"
echo ""
echo "  2. Identify the deployment responsible"
echo ""
echo "  3. Scale down the deployment to 0 replicas:"
echo "     kubectl scale deployment <name> --replicas=0 -n monitoring"
echo ""
echo "  4. Save the Falco alert line to /var/work/tests/artifacts/20/falco-alert.txt"

mkdir -p /var/work/tests/artifacts/20/
