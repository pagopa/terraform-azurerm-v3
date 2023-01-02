output "id" {
  value = jsondecode(azurerm_resource_group_template_deployment.this.output_content).id.value
}
