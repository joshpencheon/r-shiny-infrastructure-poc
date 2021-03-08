variable "name" {
  type = string
}

variable "tag" {
  type = string
}

variable "access" {
  type = string

  validation {
    condition = contains(["public", "restricted"], var.access)
    error_message = "Please specify access as being either 'public' or 'restricted'."
  }
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
