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

// SSH Key gen setup for VM

data "azurerm_client_config" "current" {}

resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault" "vm_key_vault" {
  name                = "${var.project}-${var.environment}-kv-${random_string.kv_suffix.result}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore"
    ]
  }

  tags = {
    environment = var.environment
    project     = var.project
    purpose     = "vm-ssh-keys"
  }
}

resource "random_string" "kv_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_key_vault_secret" "vm_private_key" {
  name         = "${var.project}-vm-private-key"
  value        = tls_private_key.vm_ssh_key.private_key_pem
  key_vault_id = azurerm_key_vault.vm_key_vault.id

  tags = {
    environment = var.environment
    project     = var.project
    key_type    = "ssh-private"
  }

  depends_on = [azurerm_key_vault.vm_key_vault]
}

resource "azurerm_key_vault_secret" "vm_public_key" {
  name         = "${var.project}-vm-public-key"
  value        = tls_private_key.vm_ssh_key.public_key_openssh
  key_vault_id = azurerm_key_vault.vm_key_vault.id

  tags = {
    environment = var.environment
    project     = var.project
    key_type    = "ssh-public"
  }

  depends_on = [azurerm_key_vault.vm_key_vault]
}

// VM

resource "azurerm_linux_virtual_machine" "main_vm" {
  name                            = "${var.project}-vm"
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = var.location
  size                            = "Standard_B1ls" 
  admin_username                  = "opella_admin"
  disable_password_authentication = true 
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]


  admin_ssh_key {
    username   = "opella_admin"
    public_key = tls_private_key.vm_ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" 
    disk_size_gb         = 30             
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  tags = {
    environment = var.environment
    project     = var.project
    owner       = "DevTeam"
  }
}
