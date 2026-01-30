terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    ansible = {
      source = "ansible/ansible"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}
