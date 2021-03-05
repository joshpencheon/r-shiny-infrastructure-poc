output "node_port" {
  value = kubernetes_service.shiny_auth.spec[0].port[0].node_port
}
