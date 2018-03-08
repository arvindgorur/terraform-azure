# Configure the Microsoft Azure Provider
provider "azurerm" {
	subscription_id = "${var.Subscription_ID}"
	tenant_id       = "${var.Tenant_ID}"
}

resource "azurerm_resource_group" "rg-terraform-east" {
	name			= "rg-terraform-east"
	location	= "Canada East"
}

resource "azurerm_virtual_network" "production-network" {
    name 								= "production-network"
		address_space 			= ["10.1.0.0/16"]
		location 						= "${azurerm_resource_group.rg-terraform-east.location}"
		resource_group_name = "${azurerm_resource_group.rg-terraform-east.name}"
}

resource "azurerm_network_security_group" "my-security-group" {
	name = "my-security-group"
	location = "${azurerm_resource_group.rg-terraform-east.location}"
	resource_group_name = "${azurerm_resource_group.rg-terraform-east.name}"
}
