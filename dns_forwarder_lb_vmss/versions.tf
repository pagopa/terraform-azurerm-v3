terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.30"
    }
    null = {
      source  = "hashicorp/null"
      version = "<= 3.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "<= 3.6.0"
    }
  }
}
