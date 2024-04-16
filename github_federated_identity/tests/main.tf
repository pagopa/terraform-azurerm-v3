terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<= 3.94.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_id" "unique" {
  byte_length = 3
}

locals {
  env_short = substr(random_id.unique.hex, 0, 1)
}
