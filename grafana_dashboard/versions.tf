terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<= 3.64.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.20.0"
    }
  }
}
