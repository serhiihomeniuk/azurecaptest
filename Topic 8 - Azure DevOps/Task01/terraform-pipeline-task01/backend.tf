# resource "azurerm_storage_blob" "state_lock" {
#   name                   = "terraform.tfstate.lock"
#   storage_account_name   = azurerm_storage_account.sa.name
#   storage_container_name = azurerm_storage_container.sc.name
#   type                   = "Block"
# }

terraform {
  backend "azurerm" {
    resource_group_name   = "SHomeniukTopic8"
    storage_account_name  = "sastateshomeniuk"
    container_name        = "tfcontainer"
    key                   = "terraform.tfstate"
  }
}