terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<= 3.76.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "<= 1.9.0"
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

data "azurerm_client_config" "current" {
}

resource "random_id" "unique" {
  byte_length = 3
}

locals {
  project        = "${var.prefix}${random_id.unique.hex}"
  env_short      = substr(random_id.unique.hex, 0, 1)
  rg_name        = "${local.project}-${local.env_short}-github-runner-rg"
  key_vault_name = "${local.project}-${local.env_short}-kv"
  vnet_name      = "${local.project}-${local.env_short}-vnet"
}
