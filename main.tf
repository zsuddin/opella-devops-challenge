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


resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${var.project}-vm-public-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = {
    environment = var.environment
    project     = var.project
  }
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.project}-vm-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  
  tags = {
    environment = var.environment
    project     = var.project
  }
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.vm_nsg.name
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.project}-vm-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.dev_vnet.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  tags = {
    environment = var.environment
    project     = var.project
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}