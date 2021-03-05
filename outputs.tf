# Output the node ports each app is available on:
output "shiny_auth_ports" {
  value = {
    for name, outputs in module.shiny_app:
      name => outputs.node_port
  }
}
