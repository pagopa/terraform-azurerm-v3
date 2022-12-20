terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<= 3.36.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "<= 2.2.3"
    }
  }
}
