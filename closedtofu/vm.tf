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
