resource "azurerm_resource_group" "remote_dev_env" {
  name     = "remote-dev-env"
  location = "Canada Central"
  tags = {
    "Purpose" = "Development"
  }
}