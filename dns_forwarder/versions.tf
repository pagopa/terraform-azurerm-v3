terraform {
  required_version = ">= 1.1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.20.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.2"
    }
  }
}
