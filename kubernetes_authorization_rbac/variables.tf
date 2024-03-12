variable "authorizations" {
  type = list(
    object({
      aks_id = string
      service_principal_id = string
      namespace = string
      role = string
    })
  )
}


