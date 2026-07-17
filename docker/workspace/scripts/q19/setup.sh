#!/bin/bash
echo "[*] Setting up Q19 — Cilium Network Policy with Mutual Auth"
echo ""

kubectl create namespace myapp --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null

# Label namespaces
kubectl label ns myapp app=myapp --overwrite 2>/dev/null
kubectl label ns ingress-nginx app=ingress-nginx --overwrite 2>/dev/null

# Create pods
kubectl run web -n myapp --image=nginx:1.25 --labels="app=web,tier=frontend" 2>/dev/null || true
kubectl run api -n myapp --image=nginx:1.25 --labels="app=api,tier=backend" 2>/dev/null || true
kubectl run ingress-controller -n ingress-nginx --image=nginx:1.25 --labels="app=ingress-nginx" 2>/dev/null || true

echo "[✓] Namespaces 'myapp' and 'ingress-nginx' created with pods"
echo ""
echo "Task:"
echo "  Create a CiliumNetworkPolicy in namespace 'myapp' with mutual authentication."
echo ""
echo "  Requirements:"
echo "    - Name: cnp-myapp-mutual-auth"
echo "    - Apply to pods with label app=web in namespace myapp"
echo "    - Allow ingress only from ingress-nginx namespace"
echo "    - Enable mutual authentication (authentication.mode: required)"
echo ""
echo "  Example CiliumNetworkPolicy:"
echo "    apiVersion: cilium.io/v2"
echo "    kind: CiliumNetworkPolicy"
echo "    metadata:"
echo "      name: cnp-myapp-mutual-auth"
echo "      namespace: myapp"
echo "    spec:"
echo "      endpointSelector:"
echo "        matchLabels:"
echo "          app: web"
echo "      ingress:"
echo "      - fromEndpoints:"
echo "        - matchLabels:"
echo "            k8s:io.kubernetes.pod.namespace: ingress-nginx"
echo "        authentication:"
echo "          mode: required"
