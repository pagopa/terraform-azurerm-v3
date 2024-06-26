terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.30"
    }
  }
}

data "azurerm_subscription" "current" {}
