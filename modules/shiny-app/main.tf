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

# Interpolates the k8s namespace into the Apache config template
data "template_file" "apache_proxy_config" {
  template = file("${path.module}/proxy.conf")
  vars = {
    node-name = "localhost"
    # We can't determine the node port at this stage. Would need proper egress set up.
    # node-port = kubernetes_service.shiny_auth.spec[0].port[0].node_port
    node-port = var.node_port
    app-namespace = kubernetes_namespace.shiny_app.id
  }
}

resource "kubernetes_secret" "auth0_config" {
  metadata {
    name = "shiny-auth-auth0-config-${var.name}"
    namespace = kubernetes_namespace.shiny_app.id
    labels = {
      app  = "shiny"
      tier = "auth"
    }
  }
}

# Interpolates OIDC secrets into the apache configuration
data "template_file" "apache_oidc_config" {
  template = file("${path.module}/00-oidc.conf")
  vars = {
    node-name = "localhost"
    # We can't determine the node port at this stage. Would need proper egress set up.
    # node-port = kubernetes_service.shiny_auth.spec[0].port[0].node_port
    node-port = var.node_port

    # pull these in from terraform.tfvars; they don't need to be k8s secrets.
    auth0-subdomain = var.auth0-subdomain
    auth0-client-id = var.auth0-client-id
    auth0-secret    = var.auth0-secret
    cookie-secret   = var.cookie-secret
  }
}

resource "kubernetes_config_map" "apache_config" {
  metadata {
    name = "shiny-auth-config-${var.name}"
    namespace = kubernetes_namespace.shiny_app.id
    labels = {
      app  = "shiny"
      tier = "auth"
    }
  }

  data = {
    "00-oidc.conf" = data.template_file.apache_oidc_config.rendered
    "proxy.conf"   = data.template_file.apache_proxy_config.rendered
  }
}

# The Apache container, pulled from GitHub's container registry
resource "kubernetes_deployment" "shiny_auth" {
  metadata {
    name = "shiny-auth-${var.name}"
    namespace = kubernetes_namespace.shiny_app.id
    labels = {
      app  = "shiny"
      tier = "auth"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app  = "shiny"
        tier = "auth"
      }
    }

    template {
      metadata {
        labels = {
          app  = "shiny"
          tier = "auth"
        }

        annotations = {
          # Annotate the template with the version of the config that gets
          # injected, so Terraform can re-deploy following a config change
          config_sha1 = sha1(jsonencode(kubernetes_config_map.apache_config.data))
        }
      }

      spec {
        container {
          image = "ghcr.io/joshpencheon/r-shiny-auth-poc:e5703d90d8bee896681fa0091f457a9ab6bf6424"
          name = "shiny-auth"

          volume_mount {
            mount_path = "/etc/apache2/conf.d/"
            name = "apache-config"
          }

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
        volume {
          name = "apache-config"
          config_map {
            name = kubernetes_config_map.apache_config.metadata[0].name
          }
        }
      }
    }
  }

  wait_for_rollout = false
}

# A service to allow the Apache proxy to be connected to
resource "kubernetes_service" "shiny_auth" {
  metadata {
    name = "auth"
    namespace = kubernetes_namespace.shiny_app.id
    labels = {
      app  = "shiny"
      tier = "auth"
    }
  }

  spec {
    selector = {
      app  = kubernetes_deployment.shiny_auth.metadata[0].labels.app
      tier = kubernetes_deployment.shiny_auth.metadata[0].labels.tier
    }

    port {
      port = 80
      target_port = 80

      # Set the node_port ourselves, so we can add in OIDC redirect config up front.
      node_port = var.node_port
    }

    type = "NodePort"
  }
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
  }
}
