terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.43.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "<= 2.17.0"
    }
  }
}
