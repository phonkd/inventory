# Cluster API Spawner Module - Flatcar Edition

This module manages Kubernetes cluster provisioning on Proxmox using Cluster API (CAPI) with Flatcar Container Linux.

## Prerequisites

- A Proxmox cluster with API access
- A Flatcar Container Linux VM template (ID: 211)
- A management Kubernetes cluster (e.g., k3s) with Cluster API installed
- `clusterctl` CLI tool installed
- `kubectl` configured to access the management cluster
- `sops` for handling encrypted configuration

## Manual Setup Steps

### 1. Initialize Cluster API

First, decrypt the configuration file:
```bash
sops --config .sops.yaml decrypt clusterctl.enc.yaml > clusterctl.yaml
```

Initialize CAPI with Proxmox infrastructure provider and kubeadm bootstrap/control plane providers:
```bash
clusterctl init --infrastructure proxmox --bootstrap kubeadm --control-plane kubeadm --ipam in-cluster
```

### 2. Generate Cluster Manifest

Generate the cluster configuration (you can customize the name and Kubernetes version):
```bash
clusterctl generate cluster phonkd-test-01 --kubernetes-version v1.31.0 --flavor flatcar > generated-cluster.yaml
```

**Note:** Since we're using a custom configuration, you may need to manually edit `generated-cluster.yaml` or use the provided template.

**Important:** The provided `generated-cluster.yaml` includes critical Flatcar-specific configurations:
- `format: ignition` in KubeadmConfigSpec (required for Flatcar to process bootstrap data)
- `vmIDRange` specifications (required by Proxmox CAPI provider for VM ID assignment)
- `cloudInit.format: ignition` in ProxmoxMachineTemplate

See [docs/CONTROL_PLANE_FIXES.md](docs/CONTROL_PLANE_FIXES.md) for details on these requirements.

### Bootstrap Provider

Unlike Talos, Flatcar uses the standard Kubeadm bootstrap provider which:
- Generates Ignition configs for Flatcar
- Installs Kubernetes components via kubeadm
- Configures the kubelet and container runtime
- Handles certificate generation and cluster joining

### User Access

Default user is `core` with SSH keys configured in the `KubeadmConfigSpec.users` section.

## Troubleshooting

### Memory 0b Error

If you encounter a memory 0b error, ensure the ProxmoxCluster resource includes:
```yaml
spec:
  schedulerHints:
    memoryAdjustment: 0
```

### Network Configuration

Flatcar uses systemd-networkd. The configuration includes:
- `preKubeadmCommands` to restart networkd
- DHCP-based networking by default
- DNS servers configured at the cluster level

### DHCP Reservations (Optional)

For stable IPs, create DHCP reservations after VMs are created:

1. Get VM ID:
   ```bash
   kubectl get proxmoxmachines -n kube-system -o jsonpath='{.items[0].spec.virtualMachineID}'
   ```

2. Get MAC address from Proxmox:
   ```bash
   curl -k -H "Authorization: PVEAPIToken=<token>" \
     "https://pve.../api2/json/nodes/<node>/qemu/<vmid>/config" | jq -r '.data.net0'
   ```

3. Create DHCP reservation matching the IPAM-allocated IP and MAC address

### SSH Access

SSH into control plane or worker nodes:
```bash
ssh core@<node-ip>
```

### Get Kubeconfig

Once the cluster is ready, get the kubeconfig:
```bash
clusterctl get kubeconfig phonkd-test-01 -n kube-system > phonkd-test-01.kubeconfig
export KUBECONFIG=phonkd-test-01.kubeconfig
kubectl get nodes
```

## CNI Installation

The cluster is created without a CNI (as configured). Install your preferred CNI:

### Cilium (Recommended)
```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.14/install/kubernetes/quick-install.yaml
```

### Calico
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

## Configuration Files

- `clusterctl.yaml` - Unencrypted configuration (do not commit!)
- `clusterctl.enc.yaml` - SOPS-encrypted configuration (safe to commit)
- `.sops.yaml` - SOPS configuration with age key
- `generated-cluster.yaml` - Cluster manifest
- `flatcar-notes.yaml` - Flatcar-specific notes and configuration hints

## Key Differences from Talos

| Aspect | Talos | Flatcar |
|--------|-------|---------|
| OS Type | Purpose-built for Kubernetes | General-purpose container OS |
| Configuration | Machine Config API | Ignition + cloud-init |
| Bootstrap Provider | Talos-specific | Kubeadm |
| Control Plane | TalosControlPlane | KubeadmControlPlane |
| Package Manager | None | None (container-based) |
| Updates | Talos upgrade controller | update_engine (automatic) |
| Default User | N/A (no SSH by default) | `core` |
| Init System | Custom | systemd |

## Clean Up

To delete the cluster:
```bash
kubectl delete cluster phonkd-test-01 -n kube-system
```

This will automatically clean up all associated machines and resources in Proxmox.