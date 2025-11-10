terraform {
  required_version = ">=1.3.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.33.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.45.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 5.17.0"
    }
  }

}
