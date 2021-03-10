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

### Auth0 variables:

variable "auth0-subdomain" {
  type      = string
  sensitive = true
}

variable "auth0-client-id" {
  type      = string
  sensitive = true
}

variable "auth0-secret" {
  type      = string
  sensitive = true
}

variable "cookie-secret" {
  type      = string
  sensitive = true
}

module "shiny_app" {
  source = "./modules/shiny-app"

  for_each = var.deployments

  name   = each.key
  tag    = each.value.tag
  access = each.value.access

  auth0-subdomain = var.auth0-subdomain
  auth0-client-id = var.auth0-client-id
  auth0-secret    = var.auth0-secret
  cookie-secret   = var.cookie-secret

  # Hackishly set these to known-up-front values, rather than allowing k8s to pick
  node_port = 31000 + index(keys(var.deployments), each.key)
}
