# Quick Start Guide - Flatcar Cluster Spawner

## Prerequisites Checklist

- [ ] Management k3s cluster running
- [ ] Flatcar VM template (ID: 211) created in Proxmox
- [ ] `clusterctl` installed
- [ ] `kubectl` configured for management cluster
- [ ] `sops` installed (for encrypted configs)

## Quick Deploy (5 Minutes)

### 1. Decrypt Configuration
```bash
cd inventory/modules/spawner
sops --config .sops.yaml decrypt clusterctl.enc.yaml > clusterctl.yaml
```

### 2. Initialize Cluster API (First Time Only)
```bash
clusterctl init --infrastructure proxmox --bootstrap kubeadm --control-plane kubeadm --ipam in-cluster
```

Wait for all provider pods to be ready:
```bash
kubectl get pods -A | grep capi
```

### 3. Deploy Cluster
```bash
kubectl apply -f generated-cluster.yaml
```

### 4. Watch Progress
```bash
# Watch cluster status
kubectl get clusters -n kube-system -w

# Watch machines being created
kubectl get machines -n kube-system -w

# Watch Proxmox-specific resources
kubectl get proxmoxmachines -n kube-system
```

### 5. Get Kubeconfig (Once Ready)
```bash
clusterctl get kubeconfig phonkd-test-01 -n kube-system > phonkd-test-01.kubeconfig
export KUBECONFIG=phonkd-test-01.kubeconfig
kubectl get nodes
```

### 6. Install CNI
```bash
# Cilium (recommended)
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.14/install/kubernetes/quick-install.yaml

# OR Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

### 7. Verify Cluster
```bash
kubectl get nodes
kubectl get pods -A
```

## Common Operations

### Check Cluster Status
```bash
kubectl get clusters -n kube-system
kubectl get kubeadmcontrolplane -n kube-system
kubectl get machinedeployments -n kube-system
```

### Scale Workers
```bash
kubectl scale machinedeployment phonkd-test-01-workers -n kube-system --replicas=3
```

### Scale Control Plane
```bash
kubectl patch kubeadmcontrolplane phonkd-test-01-control-plane -n kube-system \
  --type merge -p '{"spec":{"replicas":3}}'
```

### Get Node IPs
```bash
kubectl get ipaddresses -n kube-system
```

### SSH to Node
```bash
# Get node IP
NODE_IP=$(kubectl get ipaddresses -n kube-system -o jsonpath='{.items[0].spec.address}')

# SSH as core user
ssh core@$NODE_IP
```

### View Logs
```bash
# Control plane provider logs
kubectl logs -n capi-kubeadm-control-plane-system deployment/capi-kubeadm-control-plane-controller-manager -f

# Bootstrap provider logs
kubectl logs -n capi-kubeadm-bootstrap-system deployment/capi-kubeadm-bootstrap-controller-manager -f

# Proxmox provider logs
kubectl logs -n capmox-system deployment/capmox-controller-manager -f
```

### Delete Cluster
```bash
# This will delete all VMs in Proxmox automatically
kubectl delete cluster phonkd-test-01 -n kube-system
```

## Troubleshooting

### Cluster Stuck in Provisioning
```bash
# Check machine status
kubectl describe machine -n kube-system

# Check Proxmox machine status
kubectl describe proxmoxmachine -n kube-system

# Check if VMs exist in Proxmox
# Go to Proxmox UI and verify VMs are created
```

### Node Not Ready
```bash
# SSH to the node
ssh core@<node-ip>

# Check kubelet status
sudo systemctl status kubelet

# Check kubelet logs
sudo journalctl -u kubelet -f

# Check if CNI is installed
kubectl get pods -n kube-system
```

### Control Plane Endpoint Not Responding
```bash
# Check if control plane VMs are running
kubectl get machines -n kube-system

# Check API server pod
kubectl get pods -n kube-system | grep kube-apiserver

# Verify control plane endpoint IP
kubectl get proxmoxcluster phonkd-test-01 -n kube-system -o jsonpath='{.spec.controlPlaneEndpoint}'
```

### SSH Access Not Working
```bash
# Verify SSH keys are configured
kubectl get kubeadmcontrolplane phonkd-test-01-control-plane -n kube-system -o yaml | grep -A5 users

# Check if VM is accessible via Proxmox console
# Go to Proxmox UI -> VM -> Console
```

## Configuration Customization

### Change Resource Allocation
Edit `generated-cluster.yaml` and modify:
```yaml
spec:
  template:
    spec:
      memoryMiB: 16384    # Change RAM
      numCores: 4         # Change CPU cores
      numSockets: 1       # Change CPU sockets
      disks:
        bootVolume:
          sizeGb: 100     # Change disk size
```

### Change Network Settings
Edit `generated-cluster.yaml` ProxmoxCluster section:
```yaml
spec:
  ipv4Config:
    addresses:
      - 192.168.1.210-192.168.1.225  # IP range
    gateway: 192.168.1.1              # Gateway
    prefix: 25                         # Subnet mask
  dnsServers:
    - 8.8.8.8                         # DNS servers
    - 8.8.4.4
```

### Change Kubernetes Version
Edit both control plane and worker sections:
```yaml
spec:
  version: v1.31.0  # Change to desired version
```

## Important Notes

1. **Template ID:** Always use template 211 for Flatcar
2. **Default User:** SSH user is `core`, not `root`
3. **No Cloud-Init:** Flatcar uses Ignition, CAPI handles the conversion
4. **DHCP Required:** VMs need DHCP initially, can set static reservations later
5. **CNI Required:** Cluster won't be fully functional without CNI installed

## Environment Variables

Useful variables for scripts:
```bash
export KUBECONFIG_MGMT=~/.kube/config                     # Management cluster
export KUBECONFIG_WORKLOAD=phonkd-test-01.kubeconfig      # Workload cluster
export CLUSTER_NAME=phonkd-test-01
export CLUSTER_NAMESPACE=kube-system
```

## Next Steps

After cluster is running:
- Install ingress controller (nginx, traefik)
- Install storage provider (longhorn, rook-ceph)
- Install monitoring (prometheus, grafana)
- Configure RBAC and security policies
- Set up GitOps (ArgoCD, Flux)

## Resources

- Main README: [readme.md](../readme.md)
- Migration Guide: [MIGRATION_TALOS_TO_FLATCAR.md](MIGRATION_TALOS_TO_FLATCAR.md)
- Flatcar Notes: [flatcar-notes.yaml](../flatcar-notes.yaml)