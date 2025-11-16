# Flatcar Container Linux Template Setup for Proxmox

This guide walks through creating a Flatcar Container Linux VM template in Proxmox for use with Cluster API.

## Prerequisites

- Proxmox VE 7.0 or later
- Access to Proxmox web UI or SSH
- At least 50GB free storage
- Internet connection for downloading Flatcar image

## Step-by-Step Setup

### 1. Download Flatcar Image

SSH to your Proxmox node and download the latest stable Flatcar image:

```bash
# Navigate to Proxmox storage location
cd /var/lib/vz/template/iso

# Download latest stable Flatcar QEMU image
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2

# Decompress the image
bunzip2 flatcar_production_qemu_image.img.bz2

# Verify the download (optional but recommended)
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.DIGESTS
sha256sum -c flatcar_production_qemu_image.img.DIGESTS
```

### 2. Create VM

```bash
# Set VM ID (using 211 as configured)
VMID=211
NODE=wamluck  # Change to your Proxmox node name

# Create VM
qm create $VMID \
  --name flatcar-template \
  --ostype l26 \
  --memory 2048 \
  --balloon 0 \
  --cores 2 \
  --sockets 1 \
  --cpu cputype=host \
  --net0 virtio,bridge=vmbr1 \
  --serial0 socket \
  --vga serial0
```

### 3. Import Disk

```bash
# Import the Flatcar disk
qm importdisk $VMID /var/lib/vz/template/iso/flatcar_production_qemu_image.img local-lvm

# The output will show something like:
# Successfully imported disk as 'unused0:local-lvm:vm-211-disk-0'
```

### 4. Configure Disk and Boot

```bash
# Attach the imported disk
qm set $VMID --scsi0 local-lvm:vm-$VMID-disk-0

# Add cloud-init drive (required for CAPI compatibility)
qm set $VMID --ide2 local-lvm:cloudinit

# Set boot order
qm set $VMID --boot order=scsi0

# Enable QEMU Guest Agent
qm set $VMID --agent enabled=1,fstrim_cloned_disks=1

# Set SCSI controller to VirtIO SCSI
qm set $VMID --scsihw virtio-scsi-pci
```

### 5. Additional Configuration

```bash
# Enable hotplug for disk and network (useful for CAPI operations)
qm set $VMID --hotplug disk,network,usb

# Disable tablet pointer (not needed for headless)
qm set $VMID --tablet 0

# Set machine type (optional, but recommended)
qm set $VMID --machine q35

# Enable NUMA (optional, for better performance on multi-socket systems)
qm set $VMID --numa 1
```

### 6. Resize Boot Disk (Optional)

The default Flatcar image is relatively small. Resize if needed:

```bash
# Resize to 20GB (will be overridden by CAPI but good for template)
qm resize $VMID scsi0 +10G
```

### 7. Test Boot (Important!)

Before converting to template, test that the VM boots:

```bash
# Start the VM
qm start $VMID

# Monitor console
qm terminal $VMID

# Or check via Proxmox UI: Datacenter -> Node -> VM 211 -> Console
```

You should see Flatcar boot successfully. The VM won't be fully configured yet (that's handled by Ignition/CAPI).

**Press Ctrl+O to exit the terminal.**

### 8. Shutdown and Convert to Template

```bash
# Shutdown the VM
qm shutdown $VMID

# Wait for shutdown to complete
qm wait $VMID

# Convert to template
qm template $VMID
```

### 9. Verify Template

Check in Proxmox UI:
- Navigate to your node (wamluck)
- You should see VM 211 with a template icon
- Right-click and verify "Convert to template" is grayed out

## Via Proxmox Web UI (Alternative Method)

If you prefer using the web UI:

### 1. Upload Image

1. Go to your node -> local (storage) -> ISO Images
2. Upload the Flatcar image or use the Shell to download it

### 2. Create VM

1. Click "Create VM"
2. Set VM ID: `211`
3. Name: `flatcar-template`
4. OS Tab:
   - Type: Linux
   - Kernel: 5.x - 2.6
5. System Tab:
   - SCSI Controller: VirtIO SCSI
   - Qemu Agent: ✓ Enabled
   - Machine: q35
6. Disks Tab:
   - Delete default disk (we'll import Flatcar disk)
7. CPU Tab:
   - Cores: 2
   - Type: host
8. Memory Tab:
   - Memory: 2048 MB
   - Ballooning: Disabled
9. Network Tab:
   - Model: VirtIO
   - Bridge: vmbr1
10. Finish

### 3. Import Disk (via Shell)

Follow step 3-4 from CLI method above.

### 4. Add Cloud-Init Drive

1. Select VM 211
2. Hardware -> Add -> CloudInit Drive
3. Storage: local-lvm

### 5. Set Boot Order

1. Options -> Boot Order
2. Enable only scsi0
3. Drag scsi0 to top

### 6. Convert to Template

1. Right-click VM 211
2. Select "Convert to template"
3. Confirm

## Post-Setup Verification

### Check Template Configuration

```bash
qm config 211
```

Expected output should include:
```
agent: 1
boot: order=scsi0
cores: 2
cpu: host
ide2: local-lvm:vm-211-cloudinit,media=cdrom
memory: 2048
name: flatcar-template
net0: virtio=XX:XX:XX:XX:XX:XX,bridge=vmbr1
numa: 1
ostype: l26
scsi0: local-lvm:vm-211-disk-0,size=XXG
scsihw: virtio-scsi-pci
serial0: socket
sockets: 1
template: 1
vga: serial0
```

### Test Cloning (Optional)

```bash
# Clone the template to verify it works
qm clone 211 999 --name test-flatcar-clone

# Start the clone
qm start 999

# Check console
qm terminal 999

# Cleanup
qm stop 999
qm destroy 999
```

## Troubleshooting

### Image Won't Boot

- Verify the image was fully downloaded (check file size)
- Ensure SCSI controller is VirtIO SCSI
- Check boot order includes scsi0

### QEMU Guest Agent Not Working

- Flatcar includes qemu-guest-agent by default
- It starts automatically on boot
- May take 30-60 seconds to initialize
- Check with: `qm agent 211 ping` (after starting VM)

### Cloud-Init Issues

- Ensure ide2 is set to cloudinit
- CAPI will handle Ignition -> cloud-init compatibility
- Template doesn't need cloud-init configuration

### Disk Import Failed

```bash
# Check if disk exists
ls -lh /var/lib/vz/template/iso/flatcar_production_qemu_image.img

# Check storage availability
pvesm status

# Try specifying full disk path
qm importdisk 211 /var/lib/vz/template/iso/flatcar_production_qemu_image.img local-lvm --format qcow2
```

## Template Customization

### For Different Storage

If using different storage (e.g., ZFS, Ceph):

```bash
# Replace 'local-lvm' with your storage name
qm importdisk 211 /path/to/flatcar.img <your-storage-name>
qm set 211 --scsi0 <your-storage-name>:vm-211-disk-0
qm set 211 --ide2 <your-storage-name>:cloudinit
```

### For Different Network Bridge

```bash
# Change vmbr1 to your bridge
qm set 211 --net0 virtio,bridge=vmbr0
```

### For Nested Virtualization (if needed)

```bash
# Enable nested virtualization
qm set 211 --cpu host,flags=+pdpe1gb;+aes
```

## Maintenance

### Update Template to New Flatcar Version

1. Delete old template: `qm destroy 211`
2. Download new Flatcar version
3. Follow setup steps again
4. Or keep old template and create new one with different ID

### Backup Template

```bash
# Create backup
vzdump 211 --compress zstd --mode snapshot

# Backups stored in /var/lib/vz/dump/
```

## Integration with CAPI

Once template is ready:

1. Verify template ID is `211` in `clusterctl.yaml`:
   ```yaml
   TEMPLATE_VMID: "211"
   ```

2. Verify source node in `clusterctl.yaml`:
   ```yaml
   PROXMOX_SOURCENODE: "wamluck"
   ```

3. Template is ready to use with CAPI spawner module!

## Security Notes

- Template has no default passwords
- SSH access configured via CAPI kubeadm config
- Flatcar auto-updates can be configured via Ignition
- Consider network segmentation for cluster nodes

## References

- [Flatcar Container Linux Documentation](https://www.flatcar.org/docs/latest/)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Flatcar Ignition Config](https://www.flatcar.org/docs/latest/provisioning/ignition/)