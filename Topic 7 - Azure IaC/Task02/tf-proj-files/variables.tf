variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "TerraformStateRG"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "The name of the storage account (must be globally unique)"
  type        = string
  default     = "tfstatestorage12345"
}

variable "container_name" {
  description = "The name of the storage container"
  type        = string
  default     = "tfstate-container"
}

variable "state_file_name" {
  description = "The name of the Terraform state file"
  type        = string
  default     = "terraform.tfstate"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}