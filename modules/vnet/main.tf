
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.subnet_address_prefix]
}