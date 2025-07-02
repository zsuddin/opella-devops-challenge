variable "resource_group_name" {
  description = "The name of the resource group where resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}

variable "project_name" {
  description = "A short name or identifier for the project, used for naming resources."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., 'dev', 'test', 'prod') for resource tagging and naming."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the VM's network interface will be attached."
  type        = string
}

variable "vm_size" {
  description = "The size of the Virtual Machine (e.g., 'Standard_B1ls', 'Standard_DS1_v2')."
  type        = string
  default     = "Standard_B1ls"
}

variable "admin_username" {
  description = "The administrator username for the VM."
  type        = string
  default     = "azureuser"
}

variable "os_disk_size_gb" {
  description = "The size of the OS disk in GB."
  type        = number
  default     = 30
}

variable "image_publisher" {
  description = "The publisher of the source image."
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "The offer of the source image."
  type        = string
  default     = "0001-com-ubuntu-server-focal"
}

variable "image_sku" {
  description = "The SKU of the source image."
  type        = string
  default     = "20_04-lts"
}

variable "image_version" {
  description = "The version of the source image."
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "owner_tag" {
  description = "The owner tag for the VM."
  type        = string
}