# CKS Practice Lab Workspace Image
# Contains all tools needed for CKS exam practice
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV KUBE_VERSION=1.32.1
ENV TRIVY_VERSION=0.70.0
ENV FALCO_VERSION=0.39.2

# Base packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    vim \
    nano \
    jq \
    git \
    unzip \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    bash-completion \
    net-tools \
    iputils-ping \
    dnsutils \
    openssh-client \
    sudo \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# kubectl
RUN curl -fsSL "https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# kubeadm (for upgrade questions)
RUN curl -fsSL "https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/amd64/kubeadm" \
    -o /usr/local/bin/kubeadm && chmod +x /usr/local/bin/kubeadm

# helm
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# trivy
RUN curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
    -o /tmp/trivy.tar.gz && \
    tar -xzf /tmp/trivy.tar.gz -C /usr/local/bin trivy && \
    rm /tmp/trivy.tar.gz

# syft (for SBOM generation)
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# bom (kubernetes-sigs SBOM tool)
RUN curl -fsSL "https://github.com/kubernetes-sigs/bom/releases/latest/download/bom-amd64-linux" \
    -o /usr/local/bin/bom && chmod +x /usr/local/bin/bom

# kube-bench (CIS benchmark)
RUN KUBE_BENCH_VERSION=0.9.4 && \
    curl -fsSL "https://github.com/aquasecurity/kube-bench/releases/download/v${KUBE_BENCH_VERSION}/kube-bench_${KUBE_BENCH_VERSION}_linux_amd64.tar.gz" \
    -o /tmp/kube-bench.tar.gz && \
    tar -xzf /tmp/kube-bench.tar.gz -C /usr/local/bin kube-bench && \
    rm /tmp/kube-bench.tar.gz

# etcdctl
RUN ETCD_VER=v3.5.12 && \
    curl -fsSL "https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz" \
    -o /tmp/etcd.tar.gz && \
    tar -xzf /tmp/etcd.tar.gz -C /tmp && \
    mv /tmp/etcd-${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin/ && \
    rm -rf /tmp/etcd*

# ttyd (web terminal)
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

# kubectl bash completion
RUN kubectl completion bash > /etc/bash_completion.d/kubectl

# Create workspace user
RUN useradd -m -s /bin/bash -u 1000 cks && \
    echo "cks ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Working directories
RUN mkdir -p /var/work/tests/result /var/work/tests/artifacts /opt/course && \
    chown -R cks:cks /var/work /opt/course

# Copy lab setup scripts
COPY scripts/ /opt/labs/
RUN chmod +x /opt/labs/*.sh 2>/dev/null || true

# Setup shell helpers
RUN cat /opt/labs/bashrc_append >> /etc/bash.bashrc

# Entrypoint: starts ttyd serving a bash shell
USER cks
WORKDIR /home/cks

EXPOSE 7681

CMD ["ttyd", "--writable", "--port", "7681", "--base-path", "/terminal", "bash"]
