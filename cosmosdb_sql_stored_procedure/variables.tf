variable "name" {
  type        = string
  description = "The name of the Cosmos DB SQL Database"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Cosmos DB SQL Database is created."
}

variable "account_name" {
  type        = string
  description = "The name of the Cosmos DB Account to create the table within."
}

variable "database_name" {
  type        = string
  description = "The name of the Cosmos DB SQL Database to create the table within."
}

variable "container_name" {
  type        = string
  description = "The name of the Cosmos DB SQL Container."
}

variable "body" {
  type        = string
  description = "Stored procedure body to insert into the container"
}


