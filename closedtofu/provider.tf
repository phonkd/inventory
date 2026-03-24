terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.99"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

provider "proxmox" {
  endpoint = data.sops_file.secrets.data["proxmox_endpoint"]
  username = "root@pam"
  password = data.sops_file.secrets.data["proxmox_password"]
  insecure = true
}
