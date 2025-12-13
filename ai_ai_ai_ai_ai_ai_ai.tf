# Download a Debian cloud image from remote URL
resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type       = "import"
  datastore_id       = "local"
  node_name          = "pve"
  url                = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  file_name          = "debian-12-generic-amd64.qcow2"
  checksum           = "d2fbcf11fb28795842e91364d8c7b69f1870db09ff299eb94e4fbbfa510eb78d141e74c1f4bf6dfa0b7e33d0c3b66e6751886feadb4e9916f778bab1776bdf1b"
  checksum_algorithm = "sha512"
}

# Use the downloaded image in a VM
resource "proxmox_virtual_environment_vm" "my_vm" {
  node_name = "pve"

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.debian_cloud_image.id
    interface    = "virtio0"
    size         = 20
  }
}
