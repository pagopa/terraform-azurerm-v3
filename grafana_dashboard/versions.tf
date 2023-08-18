terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.25.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 1.21.0"
    }
  }
}
