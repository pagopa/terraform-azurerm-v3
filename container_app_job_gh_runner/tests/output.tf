output "random_id" {
  value = random_id.unique.hex
}

output "resource_group" {
  value       = module.runner.resource_group
  description = "Resource group name"
}

output "subnet_name" {
  value       = module.runner.subnet_name
  description = "Subnet name"
}

output "subnet_cidr" {
  value       = module.runner.subnet_cidr
  description = "Subnet CIDR blocks"
}

output "cae_name" {
  value       = module.runner.cae_name
  description = "Container App Environment name"
}

output "ca_name" {
  value       = module.runner.ca_name
  description = "Container App job name"
}
