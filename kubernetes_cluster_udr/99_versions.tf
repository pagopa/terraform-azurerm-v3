terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.97.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "<= 3.2.2"
    }
  }
}
