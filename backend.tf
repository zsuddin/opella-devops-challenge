terraform {
  backend "azurerm" {
  }
}

# Terraform Remote State Setup
# do not uncomment

# resource "azurerm_resource_group" "rg" {
#   name     = var.resource_group_name
#   location = var.location

#   tags = {
#     environment = var.environment
#     project     = var.project
#     owner       = "DevTeam"
#   }
# }

# resource "azurerm_storage_account" "sa" {
#   name                     = "${lower(var.environment)}opellatfstate"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = var.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = {
#     environment = var.environment
#     project     = "MyWebApp"
#     owner       = "OpsTeam"
#   }
# }

# resource "azurerm_storage_container" "blob_container" {
#   name                  = "${var.environment}-tfstate"
#   storage_account_id    = azurerm_storage_account.sa.id
#   container_access_type = "private" # Private access
# }
