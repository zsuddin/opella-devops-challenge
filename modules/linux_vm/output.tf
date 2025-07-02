# modules/linux_vm/outputs.tf

output "public_ip_address" {
  description = "The public IP address of the VM."
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

output "public_ip_id" {
  description = "The ID of the public IP address."
  value       = azurerm_public_ip.vm_public_ip.id
}

output "network_interface_id" {
  description = "The ID of the network interface attached to the VM."
  value       = azurerm_network_interface.vm_nic.id
}

output "network_security_group_name" {
  description = "The name of the Network Security Group."
  value       = azurerm_network_security_group.vm_nsg.name
}

output "network_security_group_id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.vm_nsg.id
}

output "vm_name" {
  description = "The name of the Linux Virtual Machine."
  value       = azurerm_linux_virtual_machine.main_vm.name
}

output "vm_id" {
  description = "The ID of the Linux Virtual Machine."
  value       = azurerm_linux_virtual_machine.main_vm.id
}

output "key_vault_name" {
  description = "The name of the Azure Key Vault created for SSH keys."
  value       = azurerm_key_vault.vm_key_vault.name
}

output "key_vault_uri" {
  description = "The URI of the Azure Key Vault created for SSH keys."
  value       = azurerm_key_vault.vm_key_vault.vault_uri
}

output "ssh_public_key_secret_id" {
  description = "The ID of the Key Vault secret storing the SSH public key."
  value       = azurerm_key_vault_secret.vm_public_key.id
}

output "ssh_private_key_secret_id" {
  description = "The ID of the Key Vault secret storing the SSH private key."
  value       = azurerm_key_vault_secret.vm_private_key.id
}