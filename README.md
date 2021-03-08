# r-shiny-infrastructure-poc
A proof-of-concept repo for deploying containerised R Shiny apps

## Usage:

With a working kubernetes cluster, you should be able to run:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Design:

* The logic for deploying Apache + R Shiny is encapsulated in the `shiny-app` Terraform module.
* This module takes configuration by being invoked in the top-level `main.tf` file.
* The `deployments.tf` contains all the R-specific options to manage multiple deployments (image + access type for each R Shiny app).
* The deployment config could have different edit rights to the rest of the repository (see `.github/CODEOWNERS`)
* The module allows the R Shiny deployments to be scaled independently of each other.
* The module allows different R Shiny deployments to be authenticated differently.
* For the purposes of this POC, no Egress is configured; just `NodePort` services to make the auth deployments accessible via host ports.
* For the purposes of this POC, OIDC demo authentication has been provided using Auth0's free service.

## Auth secrets:

This POC is configured to use Auth0 as an Identity Provider.

You'll need to provide appropriate secret values to Terraform, which will be bootstrapped into the Apache configuration:

```bash
# A starting point:
$ cp terraform.tfvars{.sample,}
```
