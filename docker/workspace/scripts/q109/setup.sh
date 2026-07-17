#!/bin/bash
echo "[*] Setting up Q109 (Mock) — AppArmor Profile"
echo ""

kubectl create namespace secure-ns --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

mkdir -p /var/work/tests/artifacts/mock/109/

cat > /var/work/tests/artifacts/mock/109/profile <<'EOF'
#include <tunables/global>

profile restricted-nginx flags=(attach_disconnected) {
  #include <abstractions/base>

  file,
  network,

  deny /etc/shadow r,
  deny /etc/passwd w,
  deny /tmp/** w,
}
EOF

echo "[✓] Namespace 'secure-ns' created"
echo "[✓] AppArmor profile at /var/work/tests/artifacts/mock/109/profile"
echo ""
echo "Task:"
echo "  1. Install the AppArmor profile 'restricted-nginx' on the node"
echo "     apparmor_parser /var/work/tests/artifacts/mock/109/profile"
echo ""
echo "  2. Create a deployment in 'secure-ns' namespace:"
echo "     - Name: secured-nginx"
echo "     - Image: nginx:1.25"
echo "     - Replicas: 3"
echo "     - Container name: nginx"
echo "     - Annotation: container.apparmor.security.beta.kubernetes.io/nginx=localhost/restricted-nginx"
echo ""
echo "  3. Verify pods are running with the profile applied"
echo "     Save pod names to /var/work/tests/artifacts/mock/109/pods.txt"
echo ""
echo "Weight: 3%"
