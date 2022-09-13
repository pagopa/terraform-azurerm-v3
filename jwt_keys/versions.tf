terraform {
  required_version = ">= 1.1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.20.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "<= 3.4.0"
    }
  }
}
