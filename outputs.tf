output "resource_group_name" {
  description = "The name of the Azure Resource Group used."
  value       = data.azurerm_resource_group.rg.name
}

output "virtual_network_id" {
  description = "The ID of the created Virtual Network."
  value       = module.dev_vnet.vnet_id
}

output "virtual_network_name" {
  description = "The name of the created Virtual Network."
  value       = module.dev_vnet.vnet_name
}

output "subnet_id" {
  description = "The ID of the created subnet within the VNet."
  value       = module.dev_vnet.subnet_id
}

output "subnet_name" {
  description = "The name of the created subnet within the VNet."
  value       = module.dev_vnet.subnet_name
}

output "vm_public_ip_address" {
  description = "The public IP address assigned to the Linux Virtual Machine."
  value       = module.dev_linux_vm.public_ip_address
}

output "vm_public_ip_id" {
  description = "The ID of the public IP address resource."
  value       = module.dev_linux_vm.public_ip_id
}

output "vm_name" {
  description = "The name of the deployed Linux Virtual Machine."
  value       = module.dev_linux_vm.vm_name
}

output "vm_id" {
  description = "The ID of the deployed Linux Virtual Machine."
  value       = module.dev_linux_vm.vm_id
}

output "vm_key_vault_uri" {
  description = "The URI of the Azure Key Vault storing the VM's SSH keys."
  value       = module.dev_linux_vm.key_vault_uri
}

output "vm_ssh_public_key_secret_id" {
  description = "The ID of the Key Vault secret containing the VM's public SSH key."
  value       = module.dev_linux_vm.ssh_public_key_secret_id
}

output "vm_ssh_private_key_secret_id" {
  description = "The ID of the Key Vault secret containing the VM's private SSH key."
  value       = module.dev_linux_vm.ssh_private_key_secret_id
}