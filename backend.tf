terraform {
  required_version = ">= 1.14"
  cloud {
    organization = "RelativeSure"
    workspaces {
      name = "terraform-infra"
    }
  }
}
