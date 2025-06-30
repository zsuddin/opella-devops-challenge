data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

module "dev_vnet" {
  source                = "./modules/vnet"
  vnet_name             = "${var.environment}-${var.location_short}-vnet"
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  vnet_address_space    = "10.10.0.0/16"
  subnet_name           = "${var.environment}-${var.location_short}-subnet"
  subnet_address_prefix = "10.10.1.0/24"
  
  tags = {
    environment = var.environment
    project     = var.project
    owner       = "DevTeam"
  }
}