#!/bin/bash
echo "[*] Setting up Q06 — OPA Gatekeeper Blacklist Images"
echo ""

# Install Gatekeeper if not present
kubectl get ns gatekeeper-system &>/dev/null || {
  echo "[*] Installing OPA Gatekeeper..."
  kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
  echo "[*] Waiting for Gatekeeper to be ready..."
  kubectl -n gatekeeper-system wait --for=condition=ready pod -l control-plane=controller-manager --timeout=120s 2>/dev/null
}

# Create ConstraintTemplate
cat <<'EOF' | kubectl apply -f -
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8strustedimages
spec:
  crd:
    spec:
      names:
        kind: K8sTrustedImages
      validation:
        openAPIV3Schema:
          type: object
          properties:
            images:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8strustedimages
        violation[{"msg": msg}] {
          image := input.review.object.spec.containers[_].image
          not startswith(image, input.parameters.images[_])
          msg := sprintf("image '%v' is not from a trusted registry", [image])
        }
EOF

# Create Constraint that allows only specific registries (NOT very-bad-registry.com)
cat <<'EOF' | kubectl apply -f -
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sTrustedImages
metadata:
  name: trusted-images
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    images:
      - "docker.io/"
      - "registry.k8s.io/"
      - "gcr.io/"
      - "ghcr.io/"
      - "public.ecr.aws/"
      - "nginx"
      - "busybox"
      - "ubuntu"
EOF

echo ""
echo "[✓] OPA Gatekeeper installed with ConstraintTemplate"
echo ""
echo "Task:"
echo "  1. Modify the K8sTrustedImages constraint to BLOCK images from 'very-bad-registry.com'"
echo "  2. The constraint should deny any pod using images from very-bad-registry.com"
echo "  3. Verify: kubectl run test --image=very-bad-registry.com/image should be DENIED"
echo ""
echo "Hint: The current constraint uses an allowlist approach."
echo "      You may need to modify the ConstraintTemplate rego to use a denylist instead,"
echo "      or ensure very-bad-registry.com is not in the allowed list."
