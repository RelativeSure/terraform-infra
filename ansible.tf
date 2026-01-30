locals {
  vms = {
    microk8s01 = module.microk8s01.ipv4_address
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/hosts.yaml"
  content = templatefile("${path.module}/ansible/hosts.yaml.tmpl", {
    vms = local.vms
  })
}
