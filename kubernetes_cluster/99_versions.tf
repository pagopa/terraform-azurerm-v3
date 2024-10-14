terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.100"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
