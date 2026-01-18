# Download a NixOS cloud image from remote URL
resource "proxmox_virtual_environment_download_file" "nixos_cloud_image" {
  content_type        = "import"
  datastore_id        = "local"
  node_name           = "oldblac"
  url                 = "https://api.s3.arnsi.ch/public/nixos.qcow2"
  file_name           = "nixos.qcow2"
  overwrite           = true
  overwrite_unmanaged = true
}

# Use the downloaded image in a VM
resource "proxmox_virtual_environment_vm" "root-vm" {
  node_name = "oldblac"
  vm_id     = 200
  on_boot   = false

  memory {
    dedicated = 5120
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "nvme1"
    import_from  = proxmox_virtual_environment_download_file.nixos_cloud_image.id
    interface    = "virtio0"
    size         = 80
  }

  initialization {
    datastore_id = "local-lvm"

    user_account {
      username = "root"
      password = "changeme"
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_vm" "core-vm" {
  node_name = "oldblac"
  vm_id     = 202

  memory {
    dedicated = 8192
  }

  cpu {
    cores = 6
    type  = "host"
    numa  = true
  }

  agent {
    enabled = true
  }

  boot_order = ["virtio0"]

  hostpci {
    device = "hostpci0"
    id     = "0000:00:02"
    pcie   = false
    rombar = true
    xvga   = true
  }

  disk {
    datastore_id = "nvme1"
    import_from  = proxmox_virtual_environment_download_file.nixos_cloud_image.id
    interface    = "virtio0"
    serial       = "vm-202-disk-0"
    size         = 120
  }
  disk {
    # disk for samba shares
    datastore_id = "nvme1"
    interface    = "virtio1"
    serial       = "vm-202-disk-1"
    size         = 1000
  }
  disk {
    # disk for s3
    datastore_id = "nvme1"
    interface    = "virtio2"
    serial       = "vm-202-disk-2"
    size         = 500
  }
  disk {
    # disk for syncthing
    datastore_id = "nvme1"
    interface    = "virtio3"
    serial       = "vm-202-disk-3"
    size         = 200
  }

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_vm" "spot-vm" {
  node_name = "oldblac"
  vm_id     = 203

  memory {
    dedicated = 2048
  }

  cpu {
    cores = 1
    type  = "host"
    numa  = true
  }

  agent {
    enabled = true
  }

  boot_order = ["virtio0"]

  # hostpci {
  #   device = "hostpci0"
  #   id     = "0000:00:1f.3" # TODO: Replace with your Audio Controller PCI ID (e.g. 00:1f.3)
  #   #pcie   = true
  # }

  disk {
    datastore_id = "nvme1"
    import_from  = proxmox_virtual_environment_download_file.nixos_cloud_image.id
    interface    = "virtio0"
    serial       = "vm-203-disk-0"
    size         = 20
  }

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}

# Download Talos cloud image from remote URL
# Note: You need to convert .raw.xz to .qcow2 first:
# 1. wget https://factory.talos.dev/image/3531bf15c8738b4bc46f2cdd7c5cd68fea388796b291117f0ee38b51a335fc47/v1.11.5/nocloud-amd64.raw.xz
# 2. xz -d nocloud-amd64.raw.xz
# 3. qemu-img convert -f raw -O qcow2 nocloud-amd64.raw talos-v1.11.5.qcow2
# 4. Upload talos-v1.11.5.qcow2 to your object storage
resource "proxmox_virtual_environment_download_file" "talos_cloud_image" {
  content_type        = "import"
  datastore_id        = "local"
  node_name           = "oldblac"
  url                 = "https://api.s3.arnsi.ch/public/talos-v1.11.6.qcow2"
  file_name           = "talos-nocloud-v1.11.6.qcow2"
  overwrite           = true
  overwrite_unmanaged = true
}

# Talos template VM
resource "proxmox_virtual_environment_vm" "talos-template" {
  node_name = "oldblac"
  vm_id     = 1000
  name      = "talos-template"
  template  = true
  on_boot   = false

  memory {
    dedicated = 2048
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "nvme1"
    import_from  = proxmox_virtual_environment_download_file.talos_cloud_image.id
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}
