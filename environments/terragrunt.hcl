# FIXME:
#
# These local values can be used for multiple environments
# They're not environment specific.
# They can be overridden via environment variables
locals {
    resource_group_name  = "serdar_dev"
    storage_account_name = "serdartfstatestorage"
    container_name       = "tfstate"
}

# TODO:
# Update azurerm provider to a more up-to-date version
# firewall related resources need to be updated
generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 2.5" //outbound_type https://github.com/terraform-providers/terraform-provider-azurerm/blob/v2.5.0/CHANGELOG.md
        }
      }
    }
EOF
}

## Inject the remote backend configuration in all the modules that includes the root file
## without having to define them in the underlying modules
# disable_dependency_optimization = true
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  # Store the terraform state files in a blob container located on an azure storage account
  config = {
    resource_group_name  = get_env("REMOTE_STATE_RESOURCE_GROUP", "${local.resource_group_name}")
    storage_account_name = get_env("REMOTE_STATE_STORAGE_ACCOUNT", "${local.storage_account_name}")
    container_name       = get_env("REMOTE_STATE_STORAGE_CONTAINER", "${local.container_name}")
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

