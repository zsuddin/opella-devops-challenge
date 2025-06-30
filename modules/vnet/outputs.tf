output "vnet_id" {
  description = "The ID of the created Virtual Network."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The name of the created Virtual Network."
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "The ID of the created subnet."
  value       = azurerm_subnet.main.id
}

output "subnet_name" {
  description = "The name of the created subnet."
  value       = azurerm_subnet.main.name
}