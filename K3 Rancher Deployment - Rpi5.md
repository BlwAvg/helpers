# K3s + Rancher + MetalLB on Raspberry Pi 5 (Compute Modules)

This guide walks through installing **K3s**, **Rancher**, **cert-manager**, and **MetalLB** on **Raspberry Pi 5 Compute Modules** running Ubuntu.

**NOTE: I HAVE NOT VERIFIED ALL THESE STEPS. This may not fully work. This took me forever to figure out and may have missed or forgotten something.**

The result:

* A working K3s cluster on RPis
* Rancher installed and reachable on **standard HTTPS (443)**
* MetalLB providing a real LAN IP for ingress
* TLS via **cert-manager + DNS-01 (via Cloudflare)**

This guide assumes a homelab / LAN environment.

---

## Prerequisites

* Raspberry Pi 5 Compute Modules (ARM64)
* Ubuntu installed on each node
* Passwordless SSH or terminal access
* One node designated as the **first K3s server** (e.g. `clusterpi01`)
* Cloudflare DNS account (for DNS-01)
* A small unused IP range on your LAN for MetalLB

---

## 1. OS Preparation (ALL NODES)

### Disable swap (required for Kubernetes)

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

### Enable cgroups (required on Raspberry Pi)

Append the following **to the end of the single line** in:

```bash
sudo nano /boot/firmware/current/cmdline.txt
```

Add:

```
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

Or use a one-liner:

```bash
sudo sed -i 's/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1/' /boot/firmware/current/cmdline.txt
```

Reboot:

```bash
sudo reboot
```

---

## 2. Install K3s

### First server node (clusterpi01)

Install K3s server:

```bash
curl -sfL https://get.k3s.io | sh -
```

Copy kubeconfig for your user:

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

Fix kubeconfig server address:

```bash
nano ~/.kube/config
```

Change:

```
server: https://127.0.0.1:6443
```

To:

```
server: https://clusterpi01:6443
```

Export kubeconfig:

```bash
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
kubectl get nodes
```

### Join additional nodes (agents or servers)

On other nodes:

```bash
curl -sfL https://get.k3s.io | \
  K3S_URL=https://clusterpi01:6443 \
  K3S_TOKEN=<TOKEN_FROM_SERVER> \
  sh -
```

---

## 3. Install Helm

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

Verify:

```bash
helm version
```

---

## 4. Install MetalLB (LoadBalancer for bare metal)

### Install MetalLB components

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
```

Wait until ready:

```bash
kubectl -n metallb-system rollout status deploy/controller
```

### Configure IP address pool

Choose unused IPs on your LAN (example shown):

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: lan-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.70.240-192.168.70.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: lan-adv
  namespace: metallb-system
spec:
  ipAddressPools:
  - lan-pool
EOF
```

### Expose Traefik via LoadBalancer

```bash
kubectl -n kube-system patch svc traefik -p '{"spec":{"type":"LoadBalancer"}}'
kubectl -n kube-system get svc traefik
```

You should now see an **EXTERNAL-IP** assigned.

---

## 5. Install cert-manager

### Add Helm repos

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

### Install cert-manager

```bash
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

Verify:

```bash
kubectl -n cert-manager get pods
```

---

## 6. Configure Cloudflare DNS-01

### Create Cloudflare API token secret

```bash
kubectl -n cert-manager create secret generic cloudflare-api-token-secret \
  --from-literal=api-token='API_TOKEN_HERE'
```

### Create ClusterIssuer

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns01-prod
spec:
  acme:
    email: letsencrypt@domain.dev
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-dns01-prod-account-key
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
EOF
```

---

## 7. Create TLS Certificate for Rancher

```bash
kubectl create namespace cattle-system --dry-run=client -o yaml | kubectl apply -f -

cat <<'EOF' | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: rancher-cert
  namespace: cattle-system
spec:
  secretName: tls-rancher-ingress
  issuerRef:
    name: letsencrypt-dns01-prod
    kind: ClusterIssuer
  dnsNames:
  - rancher.domain.dev
EOF
```

Verify:

```bash
kubectl -n cattle-system get certificate
kubectl -n cattle-system get secret tls-rancher-ingress
```

---

## 8. Install Rancher

### Add Rancher Helm repo

```bash
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
```

### Install Rancher using TLS secret

```bash
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --create-namespace \
  --set hostname=rancher.domain.dev \
  --set bootstrapPassword='test' \
  --set ingress.tls.source=secret \
  --set ingress.tls.secretName=tls-rancher-ingress
```

Wait for rollout:

```bash
kubectl -n cattle-system rollout status deploy/rancher
```

---

## 9. Access Rancher

Ensure DNS points to the MetalLB IP assigned to Traefik:

```bash
kubectl -n kube-system get svc traefik
```

Open:

```
https://rancher.domain.dev
```

Or first-time setup link:

```bash
echo https://rancher.domain.dev/dashboard/?setup=$(kubectl get secret -n cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')
```

---

## Notes

* This setup is ideal for homelabs and edge clusters
* For true HA control plane, use multiple K3s servers with embedded etcd
* MetalLB provides LAN-native LoadBalancer functionality
* DNS-01 avoids any need for inbound HTTP

---

## Cleanup

To uninstall Rancher:

```bash
helm uninstall rancher -n cattle-system
```

To uninstall MetalLB:

```bash
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
```

---

