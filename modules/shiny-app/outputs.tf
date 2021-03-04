output "node_port" {
  value = kubernetes_service.shiny_app.spec[0].port[0].node_port
}
