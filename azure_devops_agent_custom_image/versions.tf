terraform {
  required_version = ">= 1.3.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "<= 3.2.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.53.0"
    }
  }
}
