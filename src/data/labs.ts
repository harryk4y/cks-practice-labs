export interface Lab {
  id: number;
  title: string;
  category: string;
  difficulty: "Easy" | "Medium" | "Hard";
  weight: string;
  cluster: string;
  section: "lab" | "mock";
  description: string;
  requirements: string[];
  hints: string[];
  solution: string;
  verificationChecks: string[];
}

export const labs: Lab[] = [
  // ═══════════════════════════════════════════════════════════════════
  // LABS (from cks-labs-vik/tasks/cks/labs)
  // ═══════════════════════════════════════════════════════════════════
  {
    id: 1,
    title: "kubectl Contexts",
    category: "Cluster Hardening",
    difficulty: "Easy",
    weight: "1%",
    cluster: "-",
    section: "lab",
    description: "Work with kubectl contexts and extract certificate data.",
    requirements: [
      "Write all context names into `/var/work/tests/artifacts/1/contexts`, one per line",
      "Save decoded certificate of user `cluster9-admin` to `/var/work/tests/artifacts/1/cert`",
    ],
    hints: [
      "Use `kubectl config get-contexts -o name`",
      "Use `kubectl config view --raw` to see certificates",
      "Base64 decode the certificate with `base64 -d`",
    ],
    solution: `mkdir -p /var/work/tests/artifacts/1/
kubectl config get-contexts -o name > /var/work/tests/artifacts/1/contexts

# View raw config to find the cert
kubectl config view --raw

# Find cert for cluster9-admin and decode
echo "<cert-data>" | base64 -d > /var/work/tests/artifacts/1/cert`,
    verificationChecks: [
      "File `/var/work/tests/artifacts/1/contexts` contains all context names",
      "File `/var/work/tests/artifacts/1/cert` contains decoded certificate",
    ],
  },
  {
    id: 2,
    title: "Falco / Sysdig Logging",
    category: "Runtime Security",
    difficulty: "Hard",
    weight: "6%",
    cluster: "default",
    section: "lab",
    description: "Use falco or sysdig to capture pod activity in a specific log format.",
    requirements: [
      "Use `falco` or `sysdig` to prepare logs in format: `time-with-nanoseconds,container-id,container-name,user-name,kubernetes-namespace,kubernetes-pod-name`",
      "Capture logs for pod with image `nginx`",
      "Store log to `/var/work/tests/artifacts/12/log`",
    ],
    hints: [
      "SSH to the worker node where the nginx pod is running",
      "Use `sysdig --list` to find available fields",
      "Filter with `container.image=docker.io/library/nginx:latest`",
    ],
    solution: `ssh {worker_node}
sudo su

sysdig -p"%evt.time,%container.id,%container.name,%user.name,%k8s.ns.name,%k8s.pod.name" \\
  container.image=docker.io/library/nginx:latest \\
  > /var/work/tests/artifacts/12/log
# Wait ~20 seconds then Ctrl+C`,
    verificationChecks: [
      "Log file exists at `/var/work/tests/artifacts/12/log`",
      "Log contains correct format with time,container-id,name,user,ns,pod",
    ],
  },
  {
    id: 3,
    title: "Kube-API Disable NodePort Access",
    category: "Cluster Hardening",
    difficulty: "Medium",
    weight: "4%",
    cluster: "default",
    section: "lab",
    description: "Ensure the Kubernetes API server is only accessible through a ClusterIP Service.",
    requirements: [
      "Kube-API is only accessible through a ClusterIP Service (not NodePort)",
    ],
    hints: [
      "Check kube-apiserver manifest for `--kubernetes-service-node-port` flag",
      "Remove the NodePort flag and delete the existing kubernetes service",
      "The service will be recreated automatically as ClusterIP",
    ],
    solution: `# SSH to master node
ps aux | grep kube-apiserver

# Edit /etc/kubernetes/manifests/kube-apiserver.yaml
# Remove: --kubernetes-service-node-port=31000

# Delete the existing service (will be recreated as ClusterIP)
kubectl delete svc kubernetes`,
    verificationChecks: [
      "kube-apiserver has no `--kubernetes-service-node-port` flag",
      "kubernetes service is type ClusterIP",
    ],
  },
  {
    id: 4,
    title: "Pod Security Standard",
    category: "Cluster Hardening",
    difficulty: "Medium",
    weight: "4%",
    cluster: "default",
    section: "lab",
    description: "Enforce baseline Pod Security Standard on a namespace and observe admission failures.",
    requirements: [
      "Enforce the `baseline` Pod Security Standard on `team-red` namespace",
      "Delete the Pod of the Deployment",
      "Save events of ReplicaSet to `/var/work/tests/artifacts/4/events.log`",
    ],
    hints: [
      "Use `kubectl label ns` with `pod-security.kubernetes.io/enforce=baseline`",
      "After labeling, delete existing pods — new ones may fail admission",
      "Use `kubectl events replicasets.apps -n team-red` to capture events",
    ],
    solution: `kubectl label --overwrite ns team-red pod-security.kubernetes.io/enforce=baseline

# Delete all pods in ns team-red
kubectl delete po --all -n team-red --force

# Check — pods should not be recreated due to PSS violation
kubectl get po -n team-red

# Save events
mkdir -p /var/work/tests/artifacts/4/
kubectl events replicasets.apps -n team-red > /var/work/tests/artifacts/4/events.log`,
    verificationChecks: [
      "Namespace `team-red` has baseline PSS enforce label",
      "Events file exists with ReplicaSet admission errors",
    ],
  },
  {
    id: 5,
    title: "CIS Benchmark",
    category: "Cluster Hardening",
    difficulty: "Medium",
    weight: "3%",
    cluster: "default",
    section: "lab",
    description: "Run CIS Benchmark checks and fix security issues on control-plane and worker nodes.",
    requirements: [
      "CIS Benchmark (kube-bench) is installed on nodes",
      "Fix on control-plane: 1.2.17 — `--profiling` set to false (kube-apiserver)",
      "Fix on control-plane: 1.3.2 — `--profiling` set to false (controller-manager)",
      "Fix on control-plane: 1.4.1 — `--profiling` set to false (scheduler)",
      "Fix on worker node: 4.2.6 — `--protect-kernel-defaults` set to true",
    ],
    hints: [
      "Run `kube-bench run -s master -c '1.2.17,1.3.2,1.4.1'` on control-plane",
      "Edit static pod manifests in `/etc/kubernetes/manifests/`",
      "For kubelet, edit config.yaml and add `protectKernelDefaults: true`",
    ],
    solution: `# On control-plane:
sudo su
kube-bench run -s master -c '1.2.17,1.3.2,1.4.1'

# Edit /etc/kubernetes/manifests/kube-apiserver.yaml — add --profiling=false
# Edit /etc/kubernetes/manifests/kube-controller-manager.yaml — add --profiling=false
# Edit /etc/kubernetes/manifests/kube-scheduler.yaml — add --profiling=false

# On worker node:
ssh {worker-node}
sudo su
kube-bench run -s node -c 4.2.6

# Find kubelet config: systemctl status kubelet
# Edit kubelet config, add: protectKernelDefaults: true
systemctl restart kubelet

# Re-run kube-bench — all checks should PASS`,
    verificationChecks: [
      "kube-apiserver has --profiling=false",
      "kube-controller-manager has --profiling=false",
      "kube-scheduler has --profiling=false",
      "kubelet has protectKernelDefaults: true",
    ],
  },
  {
    id: 6,
    title: "OPA Gatekeeper — Blacklist Images",
    category: "Supply Chain Security",
    difficulty: "Medium",
    weight: "6%",
    cluster: "default",
    section: "lab",
    description: "Use OPA Gatekeeper to block pods from using images from an untrusted registry.",
    requirements: [
      "Cannot run a pod with an image from `very-bad-registry.com`",
    ],
    hints: [
      "Check existing CRDs: `kubectl get crd`, `kubectl get constraint`",
      "Edit the ConstraintTemplate to add the blocked registry",
      "Test with `kubectl run test --image very-bad-registry.com/test`",
    ],
    solution: `# Find existing OPA resources
kubectl get constrainttemplates
kubectl edit constrainttemplates k8strustedimages

# Add to the rego policy:
#   not startswith(image, "very-bad-registry.com/")

# Test — should be denied:
kubectl run test --image very-bad-registry.com/test
# Error from server (Forbidden): admission webhook denied the request`,
    verificationChecks: [
      "Pods with image from very-bad-registry.com are denied",
      "Admission webhook blocks the request",
    ],
  },
  {
    id: 7,
    title: "AppArmor Profile",
    category: "System Hardening",
    difficulty: "Medium",
    weight: "3%",
    cluster: "default",
    section: "lab",
    description: "Install an AppArmor profile and create a Deployment that uses it.",
    requirements: [
      "Install AppArmor profile from `/opt/course/9/profile` on the worker node",
      "Add label `security=apparmor` to the worker node",
      "Create Deployment `apparmor` in `apparmor` namespace with image `nginx:1.19.2`",
      "Container named `c1` with AppArmor profile enabled",
      "Use nodeSelector to target the worker node",
      "Save logs of the Pod into `/var/work/tests/artifacts/9/log`",
    ],
    hints: [
      "Use `apparmor_parser -q` to load the profile",
      "Use annotation `container.apparmor.security.beta.kubernetes.io/c1: localhost/<profile-name>`",
      "The profile name is inside the profile file (e.g., `very-secure`)",
    ],
    solution: `# On worker node:
ssh {worker-node}
apparmor_parser -q /opt/course/9/profile
apparmor_status

# Label the node
kubectl label node {worker-node} security=apparmor

# Create deployment YAML:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apparmor
  namespace: apparmor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apparmor
  template:
    metadata:
      labels:
        app: apparmor
      annotations:
        container.apparmor.security.beta.kubernetes.io/c1: localhost/very-secure
    spec:
      nodeSelector:
        security: apparmor
      containers:
      - image: nginx:1.19.2
        name: c1

# Apply and save logs:
kubectl apply -f apparmor.yaml
kubectl logs -n apparmor <pod-name> > /var/work/tests/artifacts/9/log`,
    verificationChecks: [
      "AppArmor profile loaded on worker node",
      "Node has label security=apparmor",
      "Deployment `apparmor` exists with correct annotations",
      "Pod logs saved to `/var/work/tests/artifacts/9/log`",
    ],
  },
  {
    id: 8,
    title: "Container Runtime Sandbox — gVisor",
    category: "Runtime Security",
    difficulty: "Medium",
    weight: "4%",
    cluster: "cluster1",
    section: "lab",
    description: "Configure gVisor RuntimeClass and use it for workloads.",
    requirements: [
      "`runsc` installed on node2 (label `node_name=node_2`)",
      "Create RuntimeClass `gvisor` with handler `runsc`",
      "Add label `RuntimeClass=runsc` to node2",
      "Update pods in Namespace `team-purple` to use RuntimeClass `gvisor`",
      "Ensure pods run on the gVisor node",
      "Write `dmesg` output of a running Pod to `/var/work/tests/artifacts/1/gvisor-dmesg`",
    ],
    hints: [
      "RuntimeClass is in the `node.k8s.io/v1` API group",
      "Use `runtimeClassName` in pod spec",
      "Add nodeSelector to ensure scheduling on the right node",
    ],
    solution: `# Create RuntimeClass
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc

kubectl apply -f runtimeclass.yaml
kubectl label nodes {node2} RuntimeClass=runsc

# Edit all deployments in team-purple:
# Add runtimeClassName: gvisor
# Add nodeSelector: RuntimeClass: runsc

# Verify and capture dmesg:
kubectl exec <pod> -n team-purple -- dmesg > /var/work/tests/artifacts/1/gvisor-dmesg`,
    verificationChecks: [
      "RuntimeClass gvisor exists with handler runsc",
      "Node2 has label RuntimeClass=runsc",
      "Deployments in team-purple use runtimeClassName gvisor",
      "dmesg output contains 'Starting gVisor'",
    ],
  },
  {
    id: 9,
    title: "Secrets in ETCD",
    category: "System Hardening",
    difficulty: "Hard",
    weight: "7%",
    cluster: "default",
    section: "lab",
    description: "Read secret content directly from etcd using etcdctl.",
    requirements: [
      "Store plaintext secret `database-access` from NS=team-green using etcdctl to `/var/work/tests/artifacts/11/plaintext`",
      "Write decoded Secret's value of key `pass` into `/var/work/tests/artifacts/11/database-password`",
    ],
    hints: [
      "Get etcd connection params from kube-apiserver manifest",
      "Use `ETCDCTL_API=3 etcdctl get /registry/secrets/<ns>/<name>`",
      "etcd certs are in `/etc/kubernetes/pki/`",
    ],
    solution: `mkdir -p /var/work/tests/artifacts/11/

# Get etcd connection params
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep etcd

# Read secret from etcd
ETCDCTL_API=3 etcdctl \\
  --cert /etc/kubernetes/pki/apiserver-etcd-client.crt \\
  --key /etc/kubernetes/pki/apiserver-etcd-client.key \\
  --cacert /etc/kubernetes/pki/etcd/ca.crt \\
  get /registry/secrets/team-green/database-access > /var/work/tests/artifacts/11/plaintext

# Find password value in the output and save it
echo "<password-value>" > /var/work/tests/artifacts/11/database-password`,
    verificationChecks: [
      "Plaintext secret stored at correct path",
      "Database password decoded and saved",
    ],
  },
  {
    id: 10,
    title: "Enable Audit Logging",
    category: "Cluster Hardening",
    difficulty: "Hard",
    weight: "7%",
    cluster: "default",
    section: "lab",
    description: "Configure API server audit logging with specific policy rules.",
    requirements: [
      "Audit logs at `/var/logs/kubernetes-api.log`",
      "Audit policy at `/etc/kubernetes/policy/log-policy.yaml`",
      "From Secret resources, level Metadata, namespace `prod`",
      "From configmaps, level RequestResponse, namespace `billing`",
    ],
    hints: [
      "Create the policy YAML with rules matching the requirements",
      "Add `--audit-policy-file` and `--audit-log-path` flags to kube-apiserver",
      "Mount the policy file (type: File) and log dir (type: DirectoryOrCreate)",
    ],
    solution: `sudo su
mkdir -p /etc/kubernetes/policy/

# Create policy file:
cat > /etc/kubernetes/policy/log-policy.yaml <<EOF
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets"]
  namespaces: ["prod"]
- level: RequestResponse
  resources:
  - group: ""
    resources: ["configmaps"]
  namespaces: ["billing"]
- level: None
EOF

# Edit /etc/kubernetes/manifests/kube-apiserver.yaml:
# Add flags:
#   --audit-policy-file=/etc/kubernetes/policy/log-policy.yaml
#   --audit-log-path=/var/logs/kubernetes-api.log
# Add volumeMounts and volumes for policy file and log dir

service kubelet restart`,
    verificationChecks: [
      "Audit policy file exists with correct rules",
      "API server has audit flags configured",
      "Audit log file is being written",
    ],
  },
  {
    id: 11,
    title: "Fix Dockerfile",
    category: "Supply Chain Security",
    difficulty: "Easy",
    weight: "4%",
    cluster: "any",
    section: "lab",
    description: "Fix a Dockerfile to use a specific base image version and non-root user.",
    requirements: [
      "Fix Dockerfile `/var/work/14/Dockerfile`: use FROM image `20.04` version",
      "Use `myuser` for running app",
      "Build image `cks:14` (podman installed on worker pc)",
    ],
    hints: [
      "Change the FROM line to `ubuntu:20.04`",
      "Create user with `useradd` and switch with `USER` directive",
      "Use `podman build . -t cks:14` to build",
    ],
    solution: `# Edit /var/work/14/Dockerfile:
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get -y install curl
RUN groupadd myuser
RUN useradd -g myuser myuser
USER myuser
CMD ["sh", "-c", "while true; do id; sleep 1; done"]

# Build and test:
podman build . -t cks:14
podman run -d --name cks-14 cks:14
sleep 2
podman logs cks-14 | grep myuser`,
    verificationChecks: [
      "Dockerfile uses ubuntu:20.04",
      "Dockerfile uses USER myuser",
      "Image cks:14 builds successfully",
    ],
  },
  {
    id: 12,
    title: "Kubernetes Cluster Upgrade",
    category: "Cluster Hardening",
    difficulty: "Hard",
    weight: "7%",
    cluster: "default",
    section: "lab",
    description: "Upgrade a Kubernetes cluster from one minor version to the next.",
    requirements: [
      "Upgrade the cluster from 1.29.0 to 1.29.1",
      "Use apt package manager and kubeadm",
      "Upgrade both control-plane and worker nodes",
    ],
    hints: [
      "Drain node first, then upgrade kubeadm, then kubelet/kubectl",
      "Use `apt-mark unhold/hold` to manage package versions",
      "Don't forget to uncordon after upgrading",
    ],
    solution: `# Drain master
kubectl drain {master} --ignore-daemonsets

# Upgrade kubeadm
apt-mark unhold kubeadm
apt install kubeadm=1.29.1-1.1 -y
apt-mark hold kubeadm
kubeadm upgrade plan
kubeadm upgrade apply v1.29.1

# Upgrade kubelet/kubectl
apt-mark unhold kubelet kubectl
apt install kubelet=1.29.1-1.1 kubectl=1.29.1-1.1 -y
apt-mark hold kubelet kubectl
systemctl restart kubelet

kubectl uncordon {master}

# Repeat for worker node:
kubectl drain {worker} --ignore-daemonsets
ssh {worker}
# Same apt install steps + kubeadm upgrade node
kubectl uncordon {worker}`,
    verificationChecks: [
      "All nodes running target version",
      "All nodes in Ready state",
      "No nodes cordoned",
    ],
  },
  {
    id: 13,
    title: "Image Vulnerability Scanning",
    category: "Supply Chain Security",
    difficulty: "Easy",
    weight: "2%",
    cluster: "-",
    section: "lab",
    description: "Use trivy to find images with specific CVEs.",
    requirements: [
      "Find images with CVE-2020-10878 or CVE-2020-1967 from the list:",
      "- nginx:1.16.1-alpine",
      "- k8s.gcr.io/kube-apiserver:v1.18.0",
      "- k8s.gcr.io/kube-controller-manager:v1.18.0",
      "- docker.io/weaveworks/weave-kube:2.7.0",
    ],
    hints: [
      "Use `trivy image <image> | grep <CVE>`",
      "Scan each image individually",
      "Both CVEs may be in different images",
    ],
    solution: `trivy i nginx:1.16.1-alpine | grep -E 'CVE-2020-10878|CVE-2020-1967'
trivy i k8s.gcr.io/kube-apiserver:v1.18.0 | grep -E 'CVE-2020-10878|CVE-2020-1967'
trivy i k8s.gcr.io/kube-controller-manager:v1.18.0 | grep -E 'CVE-2020-10878|CVE-2020-1967'
trivy i docker.io/weaveworks/weave-kube:2.7.0 | grep -E 'CVE-2020-10878|CVE-2020-1967'`,
    verificationChecks: [
      "Identified images containing the specified CVEs",
    ],
  },
  {
    id: 14,
    title: "Network Policy — Multi-tier",
    category: "Runtime Security",
    difficulty: "Hard",
    weight: "7%",
    cluster: "default",
    section: "lab",
    description: "Create network policies for a multi-tier application with strict traffic control.",
    requirements: [
      "Create default deny policy (ingress+egress) in `prod-stack-1` NS",
      "Create default deny policy in `prod-db` NS",
      "Allow access from `user-client` NS to frontend pods in `prod-stack-1`",
      "Allow access from frontend to backend pods in `prod-stack-1`",
      "Allow access from backend pods in `prod-stack-1` to mysql pods in `prod-db`",
    ],
    hints: [
      "Default deny needs empty podSelector with policyTypes Ingress+Egress",
      "Allow DNS (port 53 TCP/UDP) in egress for service discovery",
      "Use namespaceSelector with `kubernetes.io/metadata.name` label",
    ],
    solution: `# Default deny for prod-stack-1 (with DNS allowed):
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: prod-stack-1
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
  egress:
  - to:
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53

# Similar for prod-db...
# Then create allow policies for:
# user-client -> frontend (prod-stack-1)
# frontend -> backend (prod-stack-1)
# backend (prod-stack-1) -> mysql (prod-db)`,
    verificationChecks: [
      "Default deny policies exist in both namespaces",
      "Frontend reachable from user-client only",
      "Backend reachable from frontend only",
      "MySQL reachable from backend only",
    ],
  },
  {
    id: 15,
    title: "TLS Cipher Configuration",
    category: "Cluster Hardening",
    difficulty: "Hard",
    weight: "6%",
    cluster: "default",
    section: "lab",
    description: "Set TLS versions and cipher suites for kube-api and etcd.",
    requirements: [
      "kube-api: tls cipher = `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`",
      "kube-api: tls min version 1.3",
      "etcd: tls cipher = `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`",
    ],
    hints: [
      "kube-apiserver uses `--tls-cipher-suites` and `--tls-min-version=VersionTLS13`",
      "etcd uses `--cipher-suites`",
      "Edit both static pod manifests",
    ],
    solution: `# Edit /etc/kubernetes/manifests/kube-apiserver.yaml:
# Add:
#   --tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
#   --tls-min-version=VersionTLS13

# Edit /etc/kubernetes/manifests/etcd.yaml:
# Add:
#   --cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384

service kubelet restart
kubectl get nodes`,
    verificationChecks: [
      "kube-apiserver has correct --tls-cipher-suites",
      "kube-apiserver has --tls-min-version=VersionTLS13",
      "etcd has correct --cipher-suites",
      "API server is running",
    ],
  },
  {
    id: 16,
    title: "Encrypt Secrets in ETCD",
    category: "System Hardening",
    difficulty: "Hard",
    weight: "6%",
    cluster: "default",
    section: "lab",
    description: "Configure encryption at rest for secrets stored in etcd.",
    requirements: [
      "Create encryption config at `/etc/kubernetes/enc/enc.yaml` with `aescbc`, key1: `MTIzNDU2Nzg5MDEyMzQ1Ng==`, resources: secret",
      "Create a new secret `test-secret` in NS=prod, password=strongPassword",
      "Encrypt all secrets in `stage` NS with new config",
    ],
    hints: [
      "See k8s docs: tasks/administer-cluster/encrypt-data",
      "Add `--encryption-provider-config` flag to kube-apiserver",
      "Mount the enc directory into the static pod",
      "Re-encrypt with: `kubectl get secrets -n stage -o json | kubectl replace -f -`",
    ],
    solution: `mkdir -p /etc/kubernetes/enc/

cat > /etc/kubernetes/enc/enc.yaml <<EOF
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: MTIzNDU2Nzg5MDEyMzQ1Ng==
  - identity: {}
EOF

# Edit kube-apiserver manifest:
# Add: --encryption-provider-config=/etc/kubernetes/enc/enc.yaml
# Add volume mount for /etc/kubernetes/enc

service kubelet restart
kubectl get nodes

# Create test secret:
kubectl create secret generic test-secret -n prod --from-literal password=strongPassword

# Re-encrypt existing secrets:
kubectl get secrets -n stage -o json | kubectl replace -f -`,
    verificationChecks: [
      "Encryption config exists at correct path",
      "API server has --encryption-provider-config flag",
      "Secret test-secret exists in prod namespace",
      "Secrets in stage are encrypted",
    ],
  },
  {
    id: 17,
    title: "Image Policy Webhook",
    category: "Supply Chain Security",
    difficulty: "Hard",
    weight: "6%",
    cluster: "default",
    section: "lab",
    description: "Configure ImagePolicyWebhook to deny pods using images with latest tag.",
    requirements: [
      "Configure image policy webhook using existing config files",
      "Set webhook server URL to `https://image-bouncer-webhook:30020/image_policy`",
      "Pod `test-lasted` with image `nginx` (latest) should be DENIED",
      "Pod `test-tag` with image `nginx:alpine3.17` should be ALLOWED",
    ],
    hints: [
      "Edit `/etc/kubernetes/pki/webhook/admission_kube_config.yaml` to set the server URL",
      "Add `ImagePolicyWebhook` to `--enable-admission-plugins`",
      "Add `--admission-control-config-file` flag",
    ],
    solution: `# Edit webhook kubeconfig:
# /etc/kubernetes/pki/webhook/admission_kube_config.yaml
# Set server: https://image-bouncer-webhook:30020/image_policy

# Edit /etc/kubernetes/manifests/kube-apiserver.yaml:
# Add: --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook
# Add: --admission-control-config-file=/etc/kubernetes/pki/admission_config.json

service kubelet restart

# Test — should be denied:
kubectl run test-lasted --image nginx
# Error: image policy webhook backend denied

# Test — should succeed:
kubectl run test-tag --image nginx:alpine3.17
kubectl get po test-tag`,
    verificationChecks: [
      "ImagePolicyWebhook is enabled as admission plugin",
      "Pods with latest tag are denied",
      "Pods with explicit tags are allowed",
    ],
  },
  {
    id: 18,
    title: "Cilium with WireGuard Encryption",
    category: "Runtime Security",
    difficulty: "Hard",
    weight: "6%",
    cluster: "default",
    section: "lab",
    description: "Install Cilium CNI with WireGuard encryption enabled.",
    requirements: [
      "Cilium is installed with encryption enabled",
      "encryption.type is WireGuard",
      "Nodes are Ready",
      "Traffic between pod `external` (NS external) and service `finance` (NS finance) is encrypted",
    ],
    hints: [
      "Use `cilium install` with encryption flags",
      "Verify with `cilium status` and `tcpdump` on nodes",
      "Use `kubectl exec external -n external -- curl finance.finance:8080` to test",
    ],
    solution: `# Install Cilium with WireGuard:
cilium install --set encryption.enabled=true --set encryption.type=wireguard

# Wait for ready:
cilium status --wait

# Verify encryption:
kubectl exec external -n external -- curl finance.finance:8080

# Check with tcpdump on node — traffic should be encrypted (WireGuard)`,
    verificationChecks: [
      "Cilium is installed and healthy",
      "Encryption is enabled (WireGuard)",
      "Nodes are Ready",
      "Pod-to-pod traffic is encrypted",
    ],
  },
  {
    id: 19,
    title: "Cilium Network Policy with Mutual Auth",
    category: "Runtime Security",
    difficulty: "Hard",
    weight: "6%",
    cluster: "default",
    section: "lab",
    description: "Create Cilium network policy with mutual authentication enforcement.",
    requirements: [
      "Configure Cilium network policy in `myapp` namespace",
      "Allow access from pods in `ingress-nginx` namespace to app in `myapp`",
      "Enforce mutual authentication between ingress-nginx and myapp pods",
      "Verify: `curl --connect-timeout 1 http://myapp.local:30800` works",
    ],
    hints: [
      "Use CiliumNetworkPolicy CRD",
      "Set `authentication.mode: required` on the ingress rule",
      "Use `endpointSelector` to target app pods",
    ],
    solution: `apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: myapp-policy
  namespace: myapp
spec:
  endpointSelector:
    matchLabels:
      app: myapp
  ingress:
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: ingress-nginx
    authentication:
      mode: "required"

# Verify:
curl --connect-timeout 1 --max-time 1 -s http://myapp.local:30800`,
    verificationChecks: [
      "CiliumNetworkPolicy exists in myapp namespace",
      "Mutual authentication is enforced",
      "Traffic from ingress-nginx works",
    ],
  },
  {
    id: 20,
    title: "Detect Unauthorized Memory Access (Falco)",
    category: "Runtime Security",
    difficulty: "Medium",
    weight: "4%",
    cluster: "default",
    section: "lab",
    description: "Use Falco to detect a pod accessing /dev/mem and scale down its deployment.",
    requirements: [
      "Identify the pod accessing `/dev/mem` using Falco",
      "Scale down the associated deployment to 0 replicas",
    ],
    hints: [
      "Check Falco logs for /dev/mem access events",
      "Identify the pod name and trace back to its Deployment",
      "Use `kubectl scale deploy --replicas=0`",
    ],
    solution: `# Check Falco logs:
journalctl -u falco | grep "/dev/mem"
# Or: cat /var/log/falco/falco.log | grep "/dev/mem"

# Identify the pod and its deployment
kubectl get pods -A
kubectl get deploy -A

# Scale down the offending deployment:
kubectl scale deploy <deployment-name> -n <namespace> --replicas=0`,
    verificationChecks: [
      "Offending deployment scaled to 0",
      "No pods accessing /dev/mem",
    ],
  },
  {
    id: 21,
    title: "Docker Security Configuration",
    category: "System Hardening",
    difficulty: "Easy",
    weight: "3%",
    cluster: "default",
    section: "lab",
    description: "Harden Docker daemon by removing user access and fixing socket permissions.",
    requirements: [
      "Remove docker access for user `developer` (remove from docker group)",
      "Docker is NOT exposed via TCP",
      "Docker socket `/var/run/docker.sock` permissions: root user and root group only",
    ],
    hints: [
      "Use `gpasswd -d` to remove user from group",
      "Check Docker daemon config for TCP exposure",
      "Use `chown root:root` for socket ownership",
    ],
    solution: `# Remove user from docker group:
gpasswd -d developer docker

# Stop TCP exposure (edit /etc/docker/daemon.json or systemd unit):
# Remove any -H tcp://... flags

# Fix socket permissions:
chown root:root /var/run/docker.sock
chmod 660 /var/run/docker.sock

# Verify:
groups developer
ls -l /var/run/docker.sock`,
    verificationChecks: [
      "User `developer` not in docker group",
      "Docker not exposed via TCP",
      "docker.sock owned by root:root",
    ],
  },
  {
    id: 22,
    title: "Istio mTLS Policy",
    category: "Runtime Security",
    difficulty: "Hard",
    weight: "6%",
    cluster: "default",
    section: "lab",
    description: "Configure Istio mutual TLS in a namespace to enforce encrypted pod-to-pod communication.",
    requirements: [
      "Configure Istio mTLS in `market` namespace",
      "Enforce mutual authentication between pods in `market` namespace",
      "Curl from default NS to market should fail (Connection reset)",
      "Curl from within market NS should succeed (HTTP 200)",
    ],
    hints: [
      "Use Istio PeerAuthentication resource",
      "Set mode: STRICT for the namespace",
      "Only pods with Istio sidecars can communicate",
    ],
    solution: `apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: market
spec:
  mtls:
    mode: STRICT

# Test:
# From default ns (no sidecar) — should fail:
kubectl exec -it tester -- curl app.market.svc.cluster.local:8080 --head
# curl: (56) Recv failure: Connection reset by peer

# From market ns (has sidecar) — should succeed:
kubectl exec -n market -it db -- curl app.market.svc.cluster.local:8080 --head
# HTTP/1.1 200 OK`,
    verificationChecks: [
      "PeerAuthentication with STRICT mode exists in market namespace",
      "Cross-namespace traffic without sidecar is rejected",
      "Intra-namespace traffic with sidecar succeeds",
    ],
  },

  // ═══════════════════════════════════════════════════════════════════
  // MOCK EXAM (from cks-labs-vik/tasks/cks/mock/01 + 02 combined)
  // ═══════════════════════════════════════════════════════════════════
  {
    id: 101,
    title: "[Mock] gVisor Runtime Sandbox",
    category: "Runtime Security",
    difficulty: "Medium",
    weight: "4%",
    cluster: "cluster1",
    section: "mock",
    description: "Configure gVisor as a container runtime sandbox (Mock Exam).",
    requirements: [
      "runsc installed on node2 (label node_name=node_2)",
      "Create RuntimeClass `gvisor` with handler `runsc`",
      "Label node2 with `RuntimeClass=runsc`",
      "Update deployments in `team-purple` NS to use RuntimeClass gvisor",
      "Ensure pods run on gVisor node",
      "Save dmesg output to `/var/work/tests/artifacts/1/gvisor-dmesg`",
    ],
    hints: [
      "RuntimeClass is in node.k8s.io/v1 API group",
      "Use runtimeClassName + nodeSelector in pod spec",
    ],
    solution: `# Same as Lab 8 — see RuntimeClass creation and deployment patching`,
    verificationChecks: [
      "RuntimeClass exists",
      "Deployments use gvisor runtimeClass",
      "dmesg contains 'Starting gVisor'",
    ],
  },
  {
    id: 102,
    title: "[Mock] Image Vulnerability Scanning + SBOM",
    category: "Supply Chain Security",
    difficulty: "Hard",
    weight: "3%",
    cluster: "cluster1",
    section: "mock",
    description: "Scan images for vulnerabilities and generate SBOM documents.",
    requirements: [
      "Find image with highest CRITICAL vulns in `team-xxx` NS using trivy",
      "Generate CycloneDX SBOM for it → `/var/work/02/critical_image.json`",
      "Generate SPDX-Json SBOM for `registry.k8s.io/kube-scheduler:v1.32.0` using bom → `/var/work/02/kube_scheduler_sbom.json`",
      "Scan existing SBOM at `/var/work/02/check_sbom.json` for vulns → `/var/work/02/result_sbom.json`",
    ],
    hints: [
      "trivy image --severity CRITICAL to count vulns",
      "trivy image -f cyclonedx for CycloneDX format",
      "bom generate --image <img> -o spdx-json",
      "trivy sbom --format json for scanning existing SBOM",
    ],
    solution: `# Find most critical image:
kubectl get pods -n team-xxx -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\\n' | sort -u
trivy image --severity CRITICAL <each-image>

# Generate CycloneDX:
trivy image -f cyclonedx -o /var/work/02/critical_image.json <most-critical-image>

# Generate SPDX-Json with bom:
bom generate --image registry.k8s.io/kube-scheduler:v1.32.0 --format spdx-json -o /var/work/02/kube_scheduler_sbom.json

# Scan existing SBOM:
trivy sbom /var/work/02/check_sbom.json --format json -o /var/work/02/result_sbom.json`,
    verificationChecks: [
      "CycloneDX SBOM exists for critical image",
      "SPDX-Json SBOM exists for kube-scheduler",
      "Vulnerability scan results exist",
    ],
  },
  {
    id: 103,
    title: "[Mock] Audit Logging",
    category: "Cluster Hardening",
    difficulty: "Hard",
    weight: "7%",
    cluster: "cluster2",
    section: "mock",
    description: "Configure API server audit logging (Mock Exam).",
    requirements: [
      "Logs at `/var/logs/kubernetes-api.log`",
      "Policy at `/etc/kubernetes/policy/log-policy.yaml`",
      "Secrets: level Metadata, namespace prod",
      "ConfigMaps: level RequestResponse, namespace billing",
    ],
    hints: ["Same approach as Lab 10"],
    solution: `# Same as Lab 10 — create policy and configure kube-apiserver`,
    verificationChecks: ["Audit policy configured", "Logs being written"],
  },
  {
    id: 104,
    title: "[Mock] CIS Benchmark",
    category: "Cluster Hardening",
    difficulty: "Medium",
    weight: "3%",
    cluster: "cluster3",
    section: "mock",
    description: "Fix CIS Benchmark failures (Mock Exam).",
    requirements: [
      "Fix 1.2.15 — kube-apiserver --profiling=false",
      "Fix 1.3.2 — controller-manager --profiling=false",
      "Fix 1.4.1 — scheduler --profiling=false",
      "Fix 4.2.6 — kubelet --protect-kernel-defaults=true",
    ],
    hints: ["Same approach as Lab 5"],
    solution: `# Same as Lab 5 — edit static pod manifests and kubelet config`,
    verificationChecks: ["All kube-bench checks PASS"],
  },
  {
    id: 105,
    title: "[Mock] Secrets Management",
    category: "System Hardening",
    difficulty: "Easy",
    weight: "2%",
    cluster: "cluster6",
    section: "mock",
    description: "Extract secrets and create new ones with pod mounts (Mock Exam).",
    requirements: [
      "Save user from secret `db` in `team-5` NS to `/var/work/tests/artifacts/5/user`",
      "Save password to `/var/work/tests/artifacts/5/password`",
      "Create secret `db-admin` with user=xxx, password=yyyy",
      "Create pod `db-admin` (NS=team-5, image=viktoruj/cks-lab, command=sleep 60000) mounting secret to `/mnt/secret`",
    ],
    hints: [
      "kubectl get secret -o jsonpath + base64 -d",
      "kubectl create secret generic for new secret",
      "Use volume and volumeMount in pod spec",
    ],
    solution: `kubectl -n team-5 get secret db -o jsonpath='{.data.user}' | base64 -d > /var/work/tests/artifacts/5/user
kubectl -n team-5 get secret db -o jsonpath='{.data.password}' | base64 -d > /var/work/tests/artifacts/5/password
kubectl -n team-5 create secret generic db-admin --from-literal=user=xxx --from-literal=password=yyyy

# Create pod with secret mount (use YAML with volume/volumeMount)`,
    verificationChecks: ["Secret data extracted", "New secret created", "Pod running with mount"],
  },
  {
    id: 106,
    title: "[Mock] TLS Cipher Suites",
    category: "Cluster Hardening",
    difficulty: "Hard",
    weight: "6%",
    cluster: "cluster4",
    section: "mock",
    description: "Configure TLS ciphers for kube-api and etcd (Mock Exam).",
    requirements: [
      "kube-api cipher + min version 1.3",
      "etcd cipher suites",
    ],
    hints: ["Same approach as Lab 15"],
    solution: `# Same as Lab 15`,
    verificationChecks: ["Cipher suites configured", "API server running"],
  },
  {
    id: 107,
    title: "[Mock] Encrypt Secrets in ETCD",
    category: "System Hardening",
    difficulty: "Hard",
    weight: "6%",
    cluster: "cluster5",
    section: "mock",
    description: "Configure ETCD encryption at rest (Mock Exam).",
    requirements: [
      "Create encryption config with aescbc",
      "Create test-secret in prod NS",
      "Re-encrypt secrets in stage NS",
    ],
    hints: ["Same approach as Lab 16"],
    solution: `# Same as Lab 16`,
    verificationChecks: ["Encryption configured", "Secrets encrypted"],
  },
  {
    id: 108,
    title: "[Mock] Network Policy",
    category: "Runtime Security",
    difficulty: "Medium",
    weight: "6%",
    cluster: "cluster6",
    section: "mock",
    description: "Create network policies for namespace isolation (Mock Exam).",
    requirements: [
      "Default deny ingress in `prod-db` NS",
      "Allow from `prod` namespace to `prod-db`",
      "Allow from `stage` with label `role=db-connect`",
      "Allow from any NS with label `role=db-external-connect`",
    ],
    hints: [
      "Use namespaceSelector for cross-namespace access",
      "Combine namespaceSelector + podSelector for label matching",
    ],
    solution: `# Create deny-all + specific allow policies (see Lab 14 for patterns)`,
    verificationChecks: ["Default deny exists", "Allow rules correctly configured"],
  },
  {
    id: 109,
    title: "[Mock] AppArmor",
    category: "System Hardening",
    difficulty: "Medium",
    weight: "3%",
    cluster: "cluster6",
    section: "mock",
    description: "Configure AppArmor for container workloads (Mock Exam).",
    requirements: [
      "Install AppArmor profile on worker node",
      "Label node with security=apparmor",
      "Create Deployment with AppArmor profile",
      "Save pod logs",
    ],
    hints: ["Same approach as Lab 7"],
    solution: `# Same as Lab 7`,
    verificationChecks: ["Profile loaded", "Deployment running with AppArmor"],
  },
  {
    id: 110,
    title: "[Mock] Deployment Security Context",
    category: "System Hardening",
    difficulty: "Medium",
    weight: "6%",
    cluster: "cluster6",
    section: "mock",
    description: "Harden a deployment with proper security context settings.",
    requirements: [
      "Modify deployment `secure` in `secure` NS:",
      "Prevent privilege escalation",
      "Read-only root filesystem",
      "User ID 3000, Group ID 3000",
      "Allow write to `/tmp/` for container c1",
    ],
    hints: [
      "Use securityContext at pod and container level",
      "Use emptyDir volume for writable /tmp",
      "Set runAsUser, runAsGroup, fsGroup",
    ],
    solution: `kubectl edit deploy secure -n secure

# Set pod securityContext:
#   runAsUser: 3000
#   runAsGroup: 3000
# Set container securityContext:
#   allowPrivilegeEscalation: false
#   readOnlyRootFilesystem: true
# Add emptyDir volume mounted at /tmp`,
    verificationChecks: [
      "allowPrivilegeEscalation is false",
      "readOnlyRootFilesystem is true",
      "runAsUser 3000, runAsGroup 3000",
      "emptyDir at /tmp",
    ],
  },
  {
    id: 111,
    title: "[Mock] RBAC",
    category: "Cluster Hardening",
    difficulty: "Medium",
    weight: "6%",
    cluster: "cluster6",
    section: "mock",
    description: "Modify RBAC roles and bindings for service accounts.",
    requirements: [
      "Update permissions for SA `dev` in NS `rbac-1`: delete verb `delete`, add verb `watch` for pods",
      "Create new role `dev` in `rbac-2` NS: configmaps, verbs get,list",
      "Create rolebinding `dev` in `rbac-2`: SA=dev (rbac-1), role=dev",
      "Create pod `dev-rbac` NS=rbac-1, image=viktoruj/cks-lab, command=sleep 60000, SA=dev",
    ],
    hints: [
      "Use `kubectl edit role` to modify existing permissions",
      "Use `kubectl create role` and `kubectl create rolebinding`",
      "Specify SA namespace in rolebinding with --serviceaccount=rbac-1:dev",
    ],
    solution: `# Edit existing role in rbac-1:
kubectl edit role <role-name> -n rbac-1
# Remove "delete" verb, add "watch" verb for pods

# Create new role in rbac-2:
kubectl create role dev -n rbac-2 --verb=get,list --resource=configmaps

# Create rolebinding:
kubectl create rolebinding dev -n rbac-2 --role=dev --serviceaccount=rbac-1:dev

# Create pod:
kubectl run dev-rbac -n rbac-1 --image=viktoruj/cks-lab \\
  --command -- sleep 60000 --overrides='{"spec":{"serviceAccountName":"dev"}}'`,
    verificationChecks: [
      "Role in rbac-1 has watch but not delete for pods",
      "Role dev exists in rbac-2 with correct verbs",
      "RoleBinding dev exists in rbac-2",
      "Pod dev-rbac running with SA dev",
    ],
  },
  {
    id: 112,
    title: "[Mock] Falco Detection",
    category: "Runtime Security",
    difficulty: "Hard",
    weight: "6%",
    cluster: "cluster7",
    section: "mock",
    description: "Use Falco to detect /etc/shadow reads and mitigate.",
    requirements: [
      "Using Falco, prepare logs in format: `Warning read /etc/shadow ns=<ns> pod_name=<pod> user_name=<user> container_image=<image>`",
      "Store log to `/var/work/tests/artifacts/12/log`",
      "Scale down the detected Deployment to 0 pods",
    ],
    hints: [
      "Write a custom Falco rule or check existing rules for /etc/shadow",
      "Format output using Falco output fields",
      "Identify the deployment from the pod name",
    ],
    solution: `# Check Falco logs for /etc/shadow access
# Write custom rule or use built-in detection

# Save formatted output:
# journalctl -u falco | grep shadow > /var/work/tests/artifacts/12/log

# Scale down offending deployment:
kubectl scale deploy <name> -n <ns> --replicas=0`,
    verificationChecks: [
      "Falco log file exists with correct format",
      "Offending deployment scaled to 0",
    ],
  },
  {
    id: 113,
    title: "[Mock] Image Policy Webhook",
    category: "Supply Chain Security",
    difficulty: "Hard",
    weight: "6%",
    cluster: "cluster8",
    section: "mock",
    description: "Configure ImagePolicyWebhook admission (Mock Exam).",
    requirements: [
      "Configure webhook to deny images with latest tag",
      "Pod with image `nginx` (latest) should be denied",
      "Pod with image `nginx:alpine3.17` should succeed",
    ],
    hints: ["Same approach as Lab 17"],
    solution: `# Same as Lab 17`,
    verificationChecks: ["Latest images denied", "Tagged images allowed"],
  },
];

export const categories = [
  "All",
  "Cluster Hardening",
  "System Hardening",
  "Supply Chain Security",
  "Runtime Security",
];

export const sections = ["All", "lab", "mock"] as const;
