# Control Plane Configuration Fixes

## Issues Identified

When migrating from Talos to Flatcar, several critical configuration items were missing from the control plane and worker machine templates.

## Problems Found

### 1. Missing VM ID Ranges

**Issue:** The ProxmoxMachineTemplate resources lacked `vmIDRange` specifications, which are required by the Proxmox CAPI provider to properly assign VM IDs when cloning from the template.

**Impact:** 
- VMs might fail to provision
- ID conflicts could occur if multiple clusters are deployed
- Proxmox provider cannot determine which VM IDs to use

**Location:** Both control plane and worker `ProxmoxMachineTemplate` resources

### 2. Missing Ignition Format Specification

**Issue:** Flatcar Container Linux uses Ignition for initial configuration, not cloud-init. The configuration didn't specify this format, which could cause the bootstrap provider to generate incompatible cloud-init configs instead of Ignition configs.

**Impact:**
- VMs may boot but fail to initialize properly
- Kubernetes components might not install
- Network and user configuration could be ignored

**Location:** 
- `KubeadmControlPlane.spec.kubeadmConfigSpec`
- `KubeadmConfigTemplate.spec.template.spec`
- `ProxmoxMachineTemplate` cloudInit settings

## Fixes Applied

### Fix 1: Added VM ID Ranges

#### Control Plane Template
```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha1
kind: ProxmoxMachineTemplate
metadata:
  name: phonkd-test-01-control-plane
spec:
  template:
    spec:
      vmIDRange:        # ADDED
        start: 800      # ADDED
        end: 899        # ADDED
      disks:
        bootVolume:
          disk: scsi0
          sizeGb: 100
      # ... rest of config
```

#### Worker Template
```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha1
kind: ProxmoxMachineTemplate
metadata:
  name: phonkd-test-01-worker
spec:
  template:
    spec:
      vmIDRange:        # ADDED
        start: 900      # ADDED
        end: 999        # ADDED
      disks:
        bootVolume:
          disk: scsi0
          sizeGb: 100
      # ... rest of config
```

**Rationale:**
- Control plane VMs: IDs 800-899 (allows up to 100 control plane nodes)
- Worker VMs: IDs 900-999 (allows up to 100 worker nodes)
- Keeps VMs organized and prevents ID conflicts
- Template VM is ID 211, so these ranges don't conflict

### Fix 2: Added Ignition Format Specification

#### Control Plane KubeadmConfigSpec
```yaml
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
spec:
  kubeadmConfigSpec:
    format: ignition    # ADDED - tells CAPI to generate Ignition config
    clusterConfiguration:
      apiServer:
        extraArgs:
          cloud-provider: external
    # ... rest of config
```

#### Worker KubeadmConfigTemplate
```yaml
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
spec:
  template:
    spec:
      format: ignition  # ADDED - tells CAPI to generate Ignition config
      joinConfiguration:
        nodeRegistration:
          kubeletExtraArgs:
            cloud-provider: external
      # ... rest of config
```

#### ProxmoxMachineTemplate CloudInit Settings
```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha1
kind: ProxmoxMachineTemplate
spec:
  template:
    spec:
      # ... other specs
      cloudInit:
        format: ignition  # ADDED - tells Proxmox provider to use Ignition
```

**Rationale:**
- Flatcar uses Ignition v2/v3 for provisioning, not cloud-init
- CAPI's Kubeadm bootstrap provider can generate Ignition configs when `format: ignition` is specified
- Without this, the provider generates cloud-init configs that Flatcar cannot process
- This ensures proper initialization of networking, users, and Kubernetes components

## Comparison: Before and After

### Before (Broken)
```yaml
# Control Plane Template - MISSING critical fields
spec:
  template:
    spec:
      # vmIDRange: MISSING!
      disks:
        bootVolume:
          disk: scsi0
          sizeGb: 100
      # ... other config
      # cloudInit.format: MISSING!

# KubeadmConfigSpec - MISSING format
spec:
  kubeadmConfigSpec:
    # format: MISSING!
    clusterConfiguration:
      # ...
```

### After (Fixed)
```yaml
# Control Plane Template - WITH critical fields
spec:
  template:
    spec:
      vmIDRange:              # ADDED
        start: 800            # ADDED
        end: 899              # ADDED
      disks:
        bootVolume:
          disk: scsi0
          sizeGb: 100
      # ... other config
      cloudInit:              # ADDED
        format: ignition      # ADDED

# KubeadmConfigSpec - WITH format
spec:
  kubeadmConfigSpec:
    format: ignition          # ADDED
    clusterConfiguration:
      # ...
```

## Verification

After applying these fixes, verify the configuration:

### 1. Check VM IDs
```bash
# After cluster deployment, check assigned VM IDs
kubectl get proxmoxmachines -n kube-system -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.virtualMachineID}{"\n"}{end}'

# Expected output:
# phonkd-test-01-control-plane-xxxxx    8xx
# phonkd-test-01-worker-xxxxx           9xx
```

### 2. Check Ignition Config Generation
```bash
# Check if bootstrap data is generated (should be Ignition JSON)
kubectl get secrets -n kube-system | grep bootstrap

# Decode and verify format (should contain Ignition JSON)
kubectl get secret -n kube-system <bootstrap-secret-name> -o jsonpath='{.data.value}' | base64 -d | head -20
```

### 3. Verify VM Initialization
```bash
# SSH to a node after it's provisioned
ssh core@<node-ip>

# Check if Ignition ran successfully
sudo journalctl -u ignition-firstboot.service

# Verify Kubernetes components
sudo systemctl status kubelet
```

## Why These Were Missed

These issues occurred during the Talos → Flatcar migration because:

1. **VM ID Ranges**: In the original Talos configuration, these were present but were removed thinking they were optional. The Proxmox CAPI provider actually requires them for proper VM provisioning.

2. **Ignition Format**: Talos has its own configuration system, so there was no equivalent field. When converting to Kubeadm, we didn't initially realize that Flatcar requires explicit Ignition format specification.

## Additional Notes

### Ignition vs Cloud-Init

| Aspect | Cloud-Init | Ignition |
|--------|-----------|----------|
| Used By | Ubuntu, Debian, etc. | Flatcar, Fedora CoreOS |
| Format | YAML | JSON |
| When Runs | Multiple stages | First boot only |
| Flexibility | Very flexible | Declarative, immutable |

### VM ID Range Best Practices

- **Control Plane**: 800-899 (allows 100 nodes, overkill but safe)
- **Workers**: 900-999 (allows 100 workers)
- **Templates**: Below 500 (our Flatcar template is 211)
- **Other VMs**: 100-799 (for non-CAPI workloads)

## Related Documentation

- [Cluster API Kubeadm Bootstrap Provider](https://cluster-api.sigs.k8s.io/tasks/bootstrap/kubeadm-bootstrap.html)
- [Flatcar Ignition Documentation](https://www.flatcar.org/docs/latest/provisioning/ignition/)
- [Proxmox CAPI Provider Spec](https://github.com/ionos-cloud/cluster-api-provider-proxmox)

## Conclusion

These fixes ensure that:
✅ VMs are assigned proper IDs without conflicts
✅ Flatcar receives Ignition configs it can process
✅ Kubernetes components install correctly
✅ Cluster provisioning completes successfully