provider "azurerm" {
  features {}
  subscription_id            = "c80801ad-55a3-41b1-8ace-6dfc1941b712"
  skip_provider_registration = true
}

terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.5" //outbound_type https://github.com/terraform-providers/terraform-provider-azurerm/blob/v2.5.0/CHANGELOG.md
    }
  }
}
