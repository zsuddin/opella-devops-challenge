variable "environment" {
  description = "The name of the environment (e.g., 'dev', 'prod')."
  type        = string
}

variable "location" {
  description = "The Azure region for the development environment."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group for the development environment."
  type        = string
}

variable "project" {
  default = "opella"
}

variable "location_short" {
  description = "A short name for the Azure region (e.g., 'eus' for East US)."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}