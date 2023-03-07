terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.45.0"
      configuration_aliases = [azurerm.dummy]
    }
    helm = {
      source  = "hashicorp/helm"
      version = "<= 2.7.1"
    }
  }
}

provider "azurerm" {
  features {}
  alias = "dummy"
}
