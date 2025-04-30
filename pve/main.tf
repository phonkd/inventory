terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}
provider "proxmox" {
  pm_api_url = "https://pve.int.phonkd.net/api2/json"
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}
resource "proxmox_vm_qemu" "resource-name" {
  name        = "kek"
  target_node = "wamluck"
  clone = "8001-nixtemplate"
  # resources
  onboot = true
  agent = 1
  memory = 4096
  cores = 4
}
