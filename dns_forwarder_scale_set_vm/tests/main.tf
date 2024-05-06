terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "<= 3.2.1"
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

data "azurerm_subscription" "current" {}

resource "random_id" "unique" {
  byte_length = 3
}

locals {
  project           = "${var.prefix}${random_id.unique.hex}"
  source_image_name = "${local.project}-dns-forwarder-ubuntu2204-image-v1"
}
