# Migration Guide: Talos to Flatcar

This document outlines the migration from Talos Linux to Flatcar Container Linux for the Cluster API spawner module.

## Overview

This migration transitions from using Talos-specific Cluster API providers to standard Kubeadm providers with Flatcar Container Linux as the base OS.

## What Changed

### 1. VM Template
- **Old:** Talos VM template (ID: 210)
- **New:** Flatcar VM template (ID: 211)

### 2. Cluster API Providers

#### Bootstrap Provider
- **Old:** `cluster-api-bootstrap-provider-talos`
- **New:** `cluster-api-bootstrap-provider-kubeadm`

#### Control Plane Provider
- **Old:** `cluster-api-control-plane-provider-talos`
- **New:** `cluster-api-control-plane-provider-kubeadm`

#### Infrastructure Provider
- **Old:** `sidero` (Talos-specific)
- **New:** Standard `proxmox` provider (works with any OS)

### 3. Kubernetes Resource Types

#### Control Plane
- **Old:** `TalosControlPlane` (v1alpha3)
- **New:** `KubeadmControlPlane` (v1beta1)

#### Bootstrap Configuration
- **Old:** `TalosConfigTemplate` (v1alpha3)
- **New:** `KubeadmConfigTemplate` (v1beta1)

### 4. Configuration Format

#### Talos Configuration
```yaml
spec:
  controlPlaneConfig:
    controlplane:
      generateType: controlplane
      talosVersion: v1.8
      configPatches:
        - op: add
          path: /machine/network
          value: ...
```

#### Kubeadm Configuration
```yaml
spec:
  kubeadmConfigSpec:
    clusterConfiguration:
      apiServer:
        extraArgs: ...
      controllerManager:
        extraArgs: ...
    initConfiguration:
      nodeRegistration: ...
    joinConfiguration:
      nodeRegistration: ...
```

### 5. Files Modified

| File | Changes |
|------|---------|
| `clusterctl.yaml` | - Updated `TEMPLATE_VMID` from 210 to 211<br>- Removed Talos/Sidero provider configuration |
| `clusterctl.enc.yaml` | - Updated `TEMPLATE_VMID` from 210 to 211<br>- Removed Talos/Sidero provider configuration |
| `generated-cluster.yaml` | - Complete rewrite using Kubeadm providers<br>- Updated API versions to v1beta1<br>- Changed from TalosControlPlane to KubeadmControlPlane<br>- Changed from TalosConfigTemplate to KubeadmConfigTemplate<br>- Added user configuration for SSH access |
| `talos-schema.yaml` | - Renamed to `flatcar-notes.yaml`<br>- Replaced Talos extensions with Flatcar provisioning notes |
| `readme.md` | - Complete rewrite with Flatcar-specific instructions<br>- Added Flatcar template preparation guide<br>- Updated initialization commands<br>- Added troubleshooting section |

## Key Architectural Differences

### Talos Approach
1. **Purpose-built OS:** Minimal, API-driven OS designed exclusively for Kubernetes
2. **No SSH access:** Management via API only (unless explicitly enabled)
3. **Immutable:** All configuration via Machine Config
4. **Custom providers:** Requires Talos-specific CAPI providers

### Flatcar Approach
1. **Container-focused OS:** General-purpose OS optimized for containers
2. **SSH access:** Traditional access via `core` user
3. **Ignition-based:** Initial provisioning via Ignition, managed via systemd
4. **Standard providers:** Uses upstream Kubeadm CAPI providers

## Migration Steps

### For New Clusters

1. **Prepare Flatcar Template:**
   ```bash
   # Download Flatcar image
   wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2
   bunzip2 flatcar_production_qemu_image.img.bz2
   
   # Import to Proxmox as template ID 211
   # Configure with VirtIO SCSI, VirtIO network, QEMU agent
   ```

2. **Update Configuration:**
   ```bash
   # Decrypt and verify clusterctl.yaml
   sops --config .sops.yaml decrypt clusterctl.enc.yaml > clusterctl.yaml
   
   # Verify TEMPLATE_VMID is 211
   ```

3. **Initialize CAPI with Kubeadm Providers:**
   ```bash
   clusterctl init --infrastructure proxmox --bootstrap kubeadm --control-plane kubeadm --ipam in-cluster
   ```

4. **Deploy Cluster:**
   ```bash
   kubectl apply -f generated-cluster.yaml
   ```

### For Existing Talos Clusters

**Note:** There is no in-place migration path. You must create a new cluster and migrate workloads.

1. **Create new Flatcar-based cluster** using steps above
2. **Verify new cluster** is healthy
3. **Migrate workloads:**
   - Use tools like Velero for backup/restore
   - Or manually redeploy applications to new cluster
4. **Update DNS/load balancers** to point to new cluster
5. **Decommission old Talos cluster:**
   ```bash
   kubectl delete cluster <old-cluster-name> -n kube-system
   ```

## Breaking Changes

### 1. No Talos API
Flatcar doesn't have the Talos API. Use standard Kubernetes tools and SSH for management.

### 2. User Access Required
You must configure SSH keys in the `KubeadmConfigSpec.users` section. There's no API-only management like Talos.

### 3. Different Update Mechanism
- **Talos:** Controlled upgrades via Talos upgrade controller
- **Flatcar:** Automatic updates via update_engine (can be configured)

### 4. Control Plane VIP
With Talos, VIP was configured in machine config patches. With Flatcar/Kubeadm, you may need to install kube-vip or similar for HA control plane.

### 5. Cloud Provider
Both configurations use `cloud-provider: external` but the implementation details differ.

## Advantages of Flatcar

1. **Mature ecosystem:** Uses standard Kubernetes tools
2. **Broader compatibility:** Works with more CAPI providers out of the box
3. **Familiar tooling:** Standard Linux tools, SSH access
4. **Automatic updates:** Built-in update mechanism
5. **Larger community:** More documentation and community support

## Advantages of Talos (Lost)

1. **API-driven:** Everything manageable via API
2. **Minimal attack surface:** No SSH, no shell by default
3. **Integrated upgrades:** First-class Kubernetes upgrade support
4. **Purpose-built:** Designed specifically for Kubernetes

## Testing the Migration

After deploying a Flatcar-based cluster:

```bash
# Get kubeconfig
clusterctl get kubeconfig phonkd-test-01 -n kube-system > test.kubeconfig

# Test cluster
export KUBECONFIG=test.kubeconfig
kubectl get nodes
kubectl get pods -A

# Test SSH access
ssh core@<node-ip>

# Verify Flatcar version
ssh core@<node-ip> 'cat /etc/os-release'
```

## Rollback Plan

If you need to revert to Talos:

1. Keep old configuration files backed up
2. The old Talos template (ID: 210) should still exist
3. Restore `clusterctl.yaml` with TEMPLATE_VMID: "210"
4. Restore Talos provider configuration
5. Re-initialize with Talos providers:
   ```bash
   clusterctl init --infrastructure proxmox --bootstrap talos --control-plane talos
   ```

## Support and Resources

- [Flatcar Documentation](https://www.flatcar.org/docs/latest/)
- [CAPI Kubeadm Provider](https://cluster-api.sigs.k8s.io/tasks/bootstrap/kubeadm-bootstrap.html)
- [Proxmox CAPI Provider](https://github.com/ionos-cloud/cluster-api-provider-proxmox)
- [Cluster API Book](https://cluster-api.sigs.k8s.io/)

## Questions and Issues

For issues specific to this migration, check:
1. VM template is correctly prepared with Flatcar
2. QEMU guest agent is running in VMs
3. Network configuration allows DHCP
4. SSH keys are correctly configured in KubeadmConfigSpec
5. CNI is installed after cluster creation