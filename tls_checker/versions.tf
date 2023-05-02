terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.53.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "<= 2.7.1"
    }
  }
}
