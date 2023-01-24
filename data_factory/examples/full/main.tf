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
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_storage_account" "example" {
  name                     = format("example%s", random_string.name.id)
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "endpoint-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  /*
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
  */
}

resource "azurerm_private_dns_zone" "example" {
  name                = "mydomain.com"
  resource_group_name = azurerm_resource_group.example.name
}


module "full" {
  source = "../../"

  name = format("full-%s", random_string.name.id)

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
    enabled   = true
    subnet_id = azurerm_subnet.example.id
    private_dns_zone = {
      id   = azurerm_private_dns_zone.example.id
      name = azurerm_private_dns_zone.example.name
      rg   = azurerm_private_dns_zone.example.resource_group_name
    }
  }

  #WARNING: this force you to create the storage account with target.
  resources_managed_private_enpoint = { "${azurerm_storage_account.example.id}" : "blob" }

  tags = {
    CreatedBy   = "Terraform"
    Environment = "Test"
  }

}