variable "location" {
  type    = string
  default = "italynorth"
}

variable "domain" {
  type        = string
  description = "(Optional) Specifies the domain of the CosmosDB Account."
  default = ""
}


variable "capabilities" {
  type        = list(string)
  description = "The capabilities which should be enabled for this Cosmos DB account."
  default     = []
}

variable "mongo_server_version" {
  type        = string
  description = "The Server Version of a MongoDB account. Possible values are 4.0, 3.6, and 3.2."
  default     = null
}

variable "main_geo_location_zone_redundant"{
  type        = bool
  description = "Should zone redundancy be enabled for main region? Set true for prod environments"
  default = false
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "cidr_subnet_pendpoints" {
  type    = list(string)
  default = ["10.0.250.0/23"]
}


variable "offer_type" {
  type        = string
  description = "The CosmosDB account offer type. At the moment can only be set to Standard"
  default     = "Standard"
}

variable "kind" {
  type        = string
  description = "Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB."
  default = "GlobalDocumentDB"
}


variable "tags" {
  type        = map(string)
  description = "CosmosDB account example"
  default = {
    CreatedBy = "Terraform"
    Source    = "https://github.com/pagopa/terraform-azurerm-v3"
    Test      = "cosmosdb-account"
  }
}

variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "azrmtest"
}