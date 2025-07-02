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

module "dev_linux_vm" {
  source              = "./modules/linux_vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  project_name        = var.project
  environment         = var.environment
  subnet_id           = module.dev_vnet.subnet_id
  admin_username      = "opella_admin"
  vm_size             = "Standard_B1ls"
  image_publisher     = "Canonical"
  image_offer         = "0001-com-ubuntu-server-focal"
  image_sku           = "20_04-lts"
  image_version       = "latest"
  os_disk_size_gb     = 2
  tags = {
    environment = var.environment
    project     = var.project
  }
  owner_tag = "DevTeam"
}