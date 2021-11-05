resource "azurerm_resource_group" "remote_dev_env" {
  name     = "remote-dev-env"
  location = "Canada Central"
  tags = {
    "Purpose" = "Development"
  }
}

resource "azurerm_virtual_network" "remote_dev_env_vnet" {
  name = "vnet_canada_central"
  resource_group_name = azurerm_resource_group.remote_dev_env.name
  location = azurerm_resource_group.remote_dev_env.location
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "default_subnet" {
  name                 = "canada_central"
  resource_group_name  = azurerm_resource_group.remote_dev_env.name
  virtual_network_name = azurerm_virtual_network.remote_dev_env_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}