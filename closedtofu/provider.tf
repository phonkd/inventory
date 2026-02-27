terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.97"
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
  endpoint  = data.sops_file.secrets.data["proxmox_endpoint"]
  api_token = data.sops_file.secrets.data["proxmox_api_token"]
  insecure  = true
}
