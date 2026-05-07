variable "location" {
  default = "West Europe"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.38.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}


resource "azurerm_resource_group" "example" {
  name     = "example"
  location = var.location
}

resource "random_string" "name" {
  length           = 4
  special          = true
  override_special = "/@£$"
}


module "simple" {
  source = "../../"

  name = format("simple-%s", random_string.name.id)

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  custom_domain_enabled = null

  github_conf = {

    account_name    = "pagopa"
    branch_name     = "main"
    git_url         = "https://github.com/"
    repository_name = "terraform-azurerm-v3"
    root_folder     = "./src"
  }


  private_endpoint = {
    enabled   = false
    subnet_id = null
    private_dns_zone = {
      id   = null
      name = null
      rg   = null
    }
  }

  resources_managed_private_enpoint = {}

  tags = {
    CreatedBy   = "Terraform"
    Environment = "Dev"
  }

}