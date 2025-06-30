variable "vnet_name" {
  description = "The name of the Virtual Network."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the VNET will be deployed."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the VNET in CIDR format (e.g., '10.0.0.0/16')."
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet within the VNET."
  type        = string
}

variable "subnet_address_prefix" {
  description = "The address prefix for the subnet in CIDR format (e.g., '10.0.1.0/24')."
  type        = string
}

variable "nsg_id" {
  description = "(Optional) The ID of an existing Network Security Group to associate with the subnet."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}