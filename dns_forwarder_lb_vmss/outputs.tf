output "subnet_vmss_id" {
  value = local.subnet_vmss_id
}

output "subnet_lb_id" {
  value = local.subnet_lb_id
}

output "lb_id" {
  value = module.lb.azurerm_lb_id
}

output "vmss_id" {
  value = module.vmss.id
}
