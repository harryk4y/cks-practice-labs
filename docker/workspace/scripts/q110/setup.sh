#!/bin/bash
echo "[*] Setting up Q110 (Mock) — Deployment Security Context"
echo ""

kubectl create namespace hardened --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Create an insecure deployment
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: hardened
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

echo "[✓] Deployment 'web-app' created in namespace 'hardened'"
echo ""
echo "Task:"
echo "  Harden the deployment 'web-app' in namespace 'hardened' with security contexts:"
echo ""
echo "  Pod-level securityContext:"
echo "    - runAsNonRoot: true"
echo "    - runAsUser: 1000"
echo "    - runAsGroup: 1000"
echo "    - fsGroup: 2000"
echo ""
echo "  Container-level securityContext:"
echo "    - allowPrivilegeEscalation: false"
echo "    - readOnlyRootFilesystem: true"
echo "    - capabilities:"
echo "        drop: ['ALL']"
echo ""
echo "  Also add:"
echo "    - automountServiceAccountToken: false"
echo ""
echo "  Note: You may need to add writable volumes for /tmp and /var/cache/nginx"
echo ""
echo "Weight: 5%"
