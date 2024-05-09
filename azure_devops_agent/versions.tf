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

    tls = {
      source  = "hashicorp/tls"
      version = "<= 4.1.0"
    }
  }
}
