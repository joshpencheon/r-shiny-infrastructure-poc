variable "name" {
  type = string
}

variable "tag" {
  type = string
}

variable "node_port" {
  type = string
}

### Auth0 variables:

variable "auth0-subdomain" {
  type = string
}

variable "auth0-client-id" {
  type = string
}

variable "auth0-secret" {
  type = string
}

variable "cookie-secret" {
  type = string
}
