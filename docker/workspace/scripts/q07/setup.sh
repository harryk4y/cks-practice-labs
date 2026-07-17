#!/bin/bash
echo "[*] Setting up Q07 — AppArmor Profile"
echo ""

kubectl create namespace apparmor --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Create the AppArmor profile file
mkdir -p /var/work/tests/artifacts/9/
cat > /var/work/tests/artifacts/9/profile <<'EOF'
#include <tunables/global>

profile very-secure flags=(attach_disconnected) {
  #include <abstractions/base>

  file,

  # Deny all file writes
  deny /tmp/** w,
  deny /home/** w,
  deny /root/** w,
}
EOF

echo "[✓] Namespace 'apparmor' created"
echo "[✓] AppArmor profile written to /var/work/tests/artifacts/9/profile"
echo ""
echo "Task:"
echo "  1. Install the AppArmor profile on the node (apparmor_parser)"
echo "  2. Label a node with security=apparmor"
echo "  3. Create a deployment 'apparmor-deploy' in namespace 'apparmor' with:"
echo "     - Image: nginx:1.25"
echo "     - Replicas: 2"
echo "     - AppArmor annotation: container.apparmor.security.beta.kubernetes.io/secure=localhost/very-secure"
echo "     - Container name: secure"
echo "     - NodeSelector: security=apparmor"
echo "  4. Save the logs of one pod to /var/work/tests/artifacts/9/logs.txt"
