terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.50.0, <= 3.94.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "<= 1.12.1"
    }
  }
}

data "azurerm_subscription" "current" {}
