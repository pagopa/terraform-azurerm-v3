output "random_id" {
  value = random_id.unique.hex
}

output "cae_id" {
  value = module.container_app_environment.id
}
