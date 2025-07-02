# modules/linux_vm/main.tf

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${var.project_name}-vm-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.project_name}-vm-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
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
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.vm_nsg.name
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.project_name}-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# SSH Key gen setup for VM
data "azurerm_client_config" "current" {}

resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_string" "kv_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_key_vault" "vm_key_vault" {
  name                       = "${var.project_name}-${var.environment}-kv-${random_string.kv_suffix.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
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

  tags = merge(var.tags, {
    purpose = "vm-ssh-keys"
  })
}

resource "azurerm_key_vault_secret" "vm_private_key" {
  name         = "${var.project_name}-vm-private-key"
  value        = tls_private_key.vm_ssh_key.private_key_pem
  key_vault_id = azurerm_key_vault.vm_key_vault.id

  tags = merge(var.tags, {
    key_type = "ssh-private"
  })

  depends_on = [azurerm_key_vault.vm_key_vault]
}

resource "azurerm_key_vault_secret" "vm_public_key" {
  name         = "${var.project_name}-vm-public-key"
  value        = tls_private_key.vm_ssh_key.public_key_openssh
  key_vault_id = azurerm_key_vault.vm_key_vault.id

  tags = merge(var.tags, {
    key_type = "ssh-public"
  })

  depends_on = [azurerm_key_vault.vm_key_vault]
}

# VM
resource "azurerm_linux_virtual_machine" "main_vm" {
  name                            = "${var.project_name}-vm"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.vm_ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  tags = merge(var.tags, {
    owner = var.owner_tag
  })
}