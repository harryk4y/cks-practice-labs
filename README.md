# CKS Practice Labs

A web-based lab UI of CKS labs and mock exams. Hosted on EKS with spot instances, deployed via ArgoCD, with an embedded web terminal.

## Content Source

All lab content is derived from [ViktorUJ's CKS Labs](https://github.com/ViktorUJ/cks/tree/master/tasks/cks/):
- **22 Hands-on Labs** — Individual practice exercises from `cks/tasks/cks/labs/`
- **13 Mock Exam Questions** — Full exam simulation from `cks/tasks/cks/mock/01` and `mock/02`

## Features

- **35 Total Questions** — 22 labs + 13 mock exam questions
- **Section Filtering** — Switch between Labs and Mock Exam views
- **Category Filtering** — Cluster Hardening, System Hardening, Supply Chain Security, Runtime Security
- **Embedded Terminal** — ttyd-based web terminal with CKS tools
- **Verify** — Run `verify-lab <num>` in terminal to check solutions
- **Solutions** — Toggle answer visibility per question
- **Hints** — Collapsible guidance
- **Difficulty & Weight** — Shows exam weight percentage per question
- **Cost Optimized** — Spot instances, autoscaler scales workspace to 0 when idle

## Labs

| # | Title | Category | Weight | Difficulty |
|---|-------|----------|--------|------------|
| 1 | kubectl Contexts | Cluster Hardening | 1% | Easy |
| 2 | Falco / Sysdig Logging | Runtime Security | 6% | Hard |
| 3 | Kube-API Disable NodePort | Cluster Hardening | 4% | Medium |
| 4 | Pod Security Standard | Cluster Hardening | 4% | Medium |
| 5 | CIS Benchmark | Cluster Hardening | 3% | Medium |
| 6 | OPA Gatekeeper — Blacklist Images | Supply Chain Security | 6% | Medium |
| 7 | AppArmor Profile | System Hardening | 3% | Medium |
| 8 | Container Runtime Sandbox (gVisor) | Runtime Security | 4% | Medium |
| 9 | Secrets in ETCD | System Hardening | 7% | Hard |
| 10 | Enable Audit Logging | Cluster Hardening | 7% | Hard |
| 11 | Fix Dockerfile | Supply Chain Security | 4% | Easy |
| 12 | Kubernetes Cluster Upgrade | Cluster Hardening | 7% | Hard |
| 13 | Image Vulnerability Scanning | Supply Chain Security | 2% | Easy |
| 14 | Network Policy — Multi-tier | Runtime Security | 7% | Hard |
| 15 | TLS Cipher Configuration | Cluster Hardening | 6% | Hard |
| 16 | Encrypt Secrets in ETCD | System Hardening | 6% | Hard |
| 17 | Image Policy Webhook | Supply Chain Security | 6% | Hard |
| 18 | Cilium with WireGuard | Runtime Security | 6% | Hard |
| 19 | Cilium Network Policy + Mutual Auth | Runtime Security | 6% | Hard |
| 20 | Detect Unauthorized Access (Falco) | Runtime Security | 4% | Medium |
| 21 | Docker Security Configuration | System Hardening | 3% | Easy |
| 22 | Istio mTLS Policy | Runtime Security | 6% | Hard |

## Mock Exam Questions

| # | Title | Category | Weight |
|---|-------|----------|--------|
| 101 | gVisor Runtime Sandbox | Runtime Security | 4% |
| 102 | Image Vulnerability + SBOM | Supply Chain Security | 3% |
| 103 | Audit Logging | Cluster Hardening | 7% |
| 104 | CIS Benchmark | Cluster Hardening | 3% |
| 105 | Secrets Management | System Hardening | 2% |
| 106 | TLS Cipher Suites | Cluster Hardening | 6% |
| 107 | Encrypt Secrets in ETCD | System Hardening | 6% |
| 108 | Network Policy | Runtime Security | 6% |
| 109 | AppArmor | System Hardening | 3% |
| 110 | Deployment Security Context | System Hardening | 6% |
| 111 | RBAC | Cluster Hardening | 6% |
| 112 | Falco Detection | Runtime Security | 6% |
| 113 | Image Policy Webhook | Supply Chain Security | 6% |

## Quick Start

> See [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md) for full setup instructions.

```bash
# Local UI only:
npm install && npm run dev

# Full EKS deployment:
make up
```

## Tech Stack

- Next.js 14, TypeScript, Tailwind CSS, Zustand
- ttyd (web terminal), EKS (spot), Terraform, ArgoCD

## Inspired By

- [CKS/SRE Learning Platform](https://github.com/ViktorUJ/cks/tree/master/tasks/cks/) — Source of all lab content
- [KillerCoda](https://killercoda.com/) / [KodeKloud](https://kodekloud.com/) — UI pattern
