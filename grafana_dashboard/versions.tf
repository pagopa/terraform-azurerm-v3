terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30.0, <= 3.64.0"
    }
  }
}

provider "grafana" {
   alias = "cloud"

   url   = var.grafana_url 
   auth  = var.grafana_api_key 
}