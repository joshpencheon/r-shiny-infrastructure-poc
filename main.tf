terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    github = {
      source = "integrations/github"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
