terraform {
  required_version = ">= 1.3.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "<= 3.2.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "<= 2.47.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<= 3.101.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "<= 3.6.0"
    }
  }
}
