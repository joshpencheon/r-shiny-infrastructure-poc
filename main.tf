terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    github = {
      source = "hashicorp/github"
    }
  }
}

provider "kubernetes" {}
