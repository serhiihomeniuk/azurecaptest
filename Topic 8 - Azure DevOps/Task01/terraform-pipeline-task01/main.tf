provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_cli = true
}

# Use an existing storage account
data "azurerm_storage_account" "existing" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Use an existing container
data "azurerm_storage_container" "existing" {
  name                 = var.container_name
  storage_account_name = data.azurerm_storage_account.existing.name
}

# Upload files to the existing container
resource "azurerm_storage_blob" "files" {
  for_each = fileset("${path.module}/files/", "*")

  name                   = each.value
  storage_account_name   = data.azurerm_storage_account.existing.name
  storage_container_name = data.azurerm_storage_container.existing.name
  type                   = "Block"
  source                 = "${path.module}/files/${each.value}"
}