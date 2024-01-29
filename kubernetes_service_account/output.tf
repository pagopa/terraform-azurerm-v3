output "sa_token" {
  value = data.kubernetes_secret.azure_devops_secret.binary_data["token"]
}

output "sa_ca_cert" {
  value = data.kubernetes_secret.azure_devops_secret.binary_data["ca.crt"]
}
