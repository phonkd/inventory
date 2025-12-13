# Download a NixOS cloud image from remote URL
resource "proxmox_virtual_environment_download_file" "nixos_cloud_image" {
  content_type        = "import"
  datastore_id        = "local"
  node_name           = "oldblac"
  url                 = "https://hel1.your-objectstorage.com/phonkd/nixos.qcow2"
  file_name           = "nixos.qcow2"
  overwrite           = true
  overwrite_unmanaged = true
}

# Use the downloaded image in a VM
resource "proxmox_virtual_environment_vm" "root-vm" {
  node_name = "oldblac"
  vm_id     = 200

  memory {
    dedicated = 4096
  }

  cpu {
    cores = 2
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
  url                 = "https://hel1.your-objectstorage.com/phonkd/talos-v1.11.5.qcow2"
  file_name           = "talos-v1.11.5.qcow2"
  overwrite           = true
  overwrite_unmanaged = true
}

# Talos template VM
resource "proxmox_virtual_environment_vm" "talos-template" {
  node_name = "oldblac"
  vm_id     = 210
  name      = "talos-template"
  template  = true

  memory {
    dedicated = 2048
  }

  cpu {
    cores = 2
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
