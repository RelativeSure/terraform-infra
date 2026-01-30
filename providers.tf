terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.6"
    }
  }
}

provider "hcloud" {
  token = var.HCLOUD_TOKEN
}
