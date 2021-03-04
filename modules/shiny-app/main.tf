# A namespace in which to hold all the resources for this deployment
resource "kubernetes_namespace" "shiny_app" {
  metadata {
    name = "shiny-app-${var.name}"
    labels = {
      app  = "shiny"
    }
  }
}

# The R Shiny container, pulled from GitHub's container registry
resource "kubernetes_deployment" "shiny_app" {
  metadata {
    name = "shiny-app-${var.name}"
    namespace = kubernetes_namespace.shiny_app.id
    labels = {
      app  = "shiny"
      tier = "app"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app  = "shiny"
        tier = "app"
      }
    }

    template {
      metadata {
        labels = {
          app  = "shiny"
          tier = "app"
        }

      }
      spec {
        container {
          image = "ghcr.io/joshpencheon/${var.name}:${var.tag}"
          name = "shiny-app"

          # resources {
          #   limits {
          #     cpu    = "0.5"
          #     memory = "512Mi"
          #   }
          #   requests {
          #     cpu    = "250m"
          #     memory = "50Mi"
          #   }
          # }
        }
      }
    }
  }

  wait_for_rollout = false
}

# A service to allow the R Shiny app to be connected to
resource "kubernetes_service" "shiny_app" {
  metadata {
    name = "webapp"
    namespace = kubernetes_namespace.shiny_app.id
    labels = {
      app  = "shiny"
      tier = "app"
    }
  }

  spec {
    selector = {
      app  = kubernetes_deployment.shiny_app.metadata[0].labels.app
      tier = kubernetes_deployment.shiny_app.metadata[0].labels.tier
    }

    port {
      port = 80
      target_port = 3838
    }

    # cluster_ip = "None"
    type = "NodePort" # allow more direct access for now
  }
}
