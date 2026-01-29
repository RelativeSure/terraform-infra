variable "microk8s_channel" {
  type = string
  default = "1.35"
}

variable "server_name" {
  type = string
}

variable "server_image" {
  type = string
  default = "ubuntu-24.04"
}

variable "server_type" {
  type = string
  default = "cx23"
}

variable "server_location" {
  type = string
  default = "fsn1"
}

variable "server_username" {
  type = string
  default = "rasmus"
}

variable "ssh_public_key" {
  type = string
  default = ""
}
