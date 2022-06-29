locals {
  subscription_id_default            = "c80801ad-55a3-41b1-8ace-6dfc1941b712"
  subscription_id                    = get_env("AZURE_SUBSCRIPTION_ID", "${local.subscription_id_default}")
}

# Inject this provider configuration in all the modules that includes the root file
# without having to define them in the underlying modules
# This instructs Terragrunt to create the file provider.tf in the working directory
# (where Terragrunt calls terraform) before it calls any of the Terraform commands
# (e.g plan, apply, validate, etc)
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  subscription_id = "${local.subscription_id}"
  features {}
  skip_provider_registration = true
}
EOF
}

include "root" {
  path = find_in_parent_folders()
}
