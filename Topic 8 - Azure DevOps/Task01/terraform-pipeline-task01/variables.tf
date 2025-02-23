variable "storage_account_name" {
  description = "Name of the existing Azure Storage Account"
  type        = string
  default = "sastateshomeniuk"
}

variable "resource_group_name" {
  description = "Name of the resource group where the storage account is located"
  type        = string
  default = "SHomeniukTopic8"
}

variable "container_name" {
  description = "Name of the existing container in the storage account"
  type        = string
  default = "tfcontainer"
}

variable "subscription_id" {
  description = "The subscription ID"
  type        = string
  default     = "9a6ae428-d8c3-44fe-bdf2-4e08593901a0"
}

# variable "client_id" {
#   description = "The client ID of the Service Principal"
#   type        = string
#   default     = "d3e0c1b3-9e5e-4bff-890f-abb1d0b95b27"
# }

# variable "client_secret" {
#   description = "The client secret of the Service Principal"
#   type        = string
#   sensitive   = true
# }

# variable "tenant_id" {
#   description = "The tenant ID"
#   type        = string
# }