terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.97.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "<= 2.14.3"
    }
  }
}
