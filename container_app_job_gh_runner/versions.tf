terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.44.0, <= 3.76.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "<= 1.9.0"
    }
  }
}

data "azurerm_subscription" "current" {}
