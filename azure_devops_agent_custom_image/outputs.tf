output "custom_image_name" {
  value       = local.target_image_name
  description = "Name of the created image"
}

output "custom_image_id" {
  value       = local.target_image_id
  description = "Azure id of the custom image you just created"
}

