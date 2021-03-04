terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "shiny_app" {
  source = "./modules/shiny-app"

  for_each = var.deployments

  name = each.key
  tag  = each.value.tag
}
