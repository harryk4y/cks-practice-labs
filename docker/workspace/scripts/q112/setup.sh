#!/bin/bash
echo "[*] Setting up Q112 (Mock) — Falco Detection (/etc/shadow read)"
echo ""

kubectl create namespace suspicious --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Create a deployment that reads /etc/shadow
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shadow-reader
  namespace: suspicious
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shadow-reader
  template:
    metadata:
      labels:
        app: shadow-reader
    spec:
      containers:
      - name: reader
        image: busybox
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            cat /etc/shadow 2>/dev/null || true
            sleep 60
          done
EOF

mkdir -p /var/work/tests/artifacts/mock/112/

echo "[✓] Deployment 'shadow-reader' created in namespace 'suspicious'"
echo ""
echo "Task:"
echo "  A pod is reading /etc/shadow, which is a security concern."
echo "  Use Falco to detect and respond to this threat."
echo ""
echo "  1. Check Falco logs for alerts about /etc/shadow access:"
echo "     kubectl logs -l app=falco -n falco | grep shadow"
echo "     OR: grep shadow /var/log/syslog | grep falco"
echo ""
echo "  2. Identify which pod/deployment is the offender"
echo ""
echo "  3. Scale down the offending deployment to 0 replicas"
echo ""
echo "  4. Save the relevant Falco alert to /var/work/tests/artifacts/mock/112/alert.txt"
echo ""
echo "  5. Save the pod name to /var/work/tests/artifacts/mock/112/pod-name.txt"
echo ""
echo "Weight: 4%"
