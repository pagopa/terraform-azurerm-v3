terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_id" "unique" {
  byte_length = 3
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

locals {
  project = "${var.prefix}${random_id.unique.hex}"
}
