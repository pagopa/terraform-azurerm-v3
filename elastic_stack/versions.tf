terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.97.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "<= 2.27.0"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}
