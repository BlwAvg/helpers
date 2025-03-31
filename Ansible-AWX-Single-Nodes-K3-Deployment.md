# AWX on K3s (Ubuntu Edition)

This guide is adapted from the original repository:  
**Sourced from here**: https://github.com/kurokobo/awx-on-k3s

## Overview

This walkthrough will help you deploy AWX on a single-node K3s Kubernetes cluster running on Ubuntu. It covers system prep, K3s installation, AWX Operator setup, certificate generation, and deploying AWX itself.

---

## 1. Prepare the System

Update your Ubuntu system and install required packages:

```bash
sudo apt update && sudo apt upgrade -y
```

## 2. Install K3s

Install K3s with kubeconfig readable for your user:

```bash
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
```

Verify K3s is running:
```bash
kubectl get nodes
```

## 3. Clone the AWX on K3s Repo
```bash
git clone https://github.com/kurokobo/awx-on-k3s.git
cd awx-on-k3s/
```

## 4. Deploy the AWX Operator
```bash
kubectl apply -k operator
kubectl -n awx get all
```

## 5. Prepare TLS Certificate
You can use a self-signed certificate or bring your own. To generate one manually:
```bash
AWX_HOST="YOUR.DOMAIN.HERE"

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -out ./base/tls.crt -keyout ./base/tls.key \
  -subj "/CN=${AWX_HOST}/O=${AWX_HOST}" \
  -addext "subjectAltName = DNS:${AWX_HOST}"
````

## 6. Update Configuration Files
`base/awx.yaml`
- Update the `hostname` to match your `AWX_HOST`
- Set a secure admin password

`base/kustomization.yaml`
- Update both password references:
  - `awx-postgres-configuration`
  - `awx-admin-password`

## 7. Set Up Persistent Volumes
```bash
sudo mkdir -p /data/postgres-15
sudo mkdir -p /data/projects
sudo chown 1000:0 /data/projects
```

## 8. Deploy AWX
```bash
kubectl apply -k base
```

Monitor the operator logs to ensure successful deployment:
```bash
kubectl -n awx logs -f deployments/awx-operator-controller-manager
```
