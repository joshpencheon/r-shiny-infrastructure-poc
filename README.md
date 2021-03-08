# r-shiny-infrastructure-poc
A proof-of-concept repo for deploying containerised R Shiny apps

## Usage:

With a working kubernetes cluster, you should be able to run:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Auth secrets:

This POC is configured to use Auth0 as an Identity Provider.

You'll need to provide appropriate secret values to Terraform, which will be bootstrapped into the Apache configuration:

```bash
# A starting point:
$ cp terraform.tfvars{.sample,}
```
