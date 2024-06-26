terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.76, != 3.97.0, != 3.97.1"
    }
  }
}
