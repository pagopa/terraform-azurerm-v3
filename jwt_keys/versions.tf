terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.45.0"
      configuration_aliases = [azurerm.dummy]
    }
    tls = {
      source  = "hashicorp/tls"
      version = "<= 4.0.4"
    }
  }
}

provider "azurerm" {
  features {}
  alias = "dummy"
}
