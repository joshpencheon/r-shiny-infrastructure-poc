variable "deployments" {
  description = "All the deployed R Shiny applications"
  type        = map

  default = {
    demo-app-1 = {
      tag  = "809930c814c8a5ba8c41bfe410dfb8834cd85507"
      access = "restricted"
    },
    demo-app-2 = {
      tag  = "d0cfc898154eea553dbe8ec2a8e6667f6abb9089"
      access = "public"
    }
  }
}
