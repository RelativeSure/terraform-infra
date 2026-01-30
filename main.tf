module "microk8s01" {
  source         = "./modules/hetzner"
  server_name    = "microk8s01"
  ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFk4XergcpJB21tDHTp8sjccfIDlq3q1/Btw0qVBqzXR rasmus@Rasmus-PC"
}
