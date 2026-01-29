terraform {
  cloud {
    organization = "RelativeSure"
    workspaces {
      name = "terraform-infra"
    }
  }
}
