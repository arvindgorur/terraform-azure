# Configure the Microsoft Azure Provider
provider "azurerm" {
	subscription_id = "${var.Subscription_ID}"
	tenant_id       = "${var.Tenant_ID}"
}

resource "azurerm_resource_group" "rg-terraform-east" {
	name			= "rg-terraform-east"
	location 	= "Canada East"
}

resource "azurerm_virtual_network" "production-network" {
	name 								= "production-network"
	address_space 			= ["10.1.0.0/16"]
	location 						= "${azurerm_resource_group.rg-terraform-east.location}"
	resource_group_name = "${azurerm_resource_group.rg-terraform-east.name}"
}

resource "azurerm_subnet" "YYZ" {
	name 									= "YYZ"
	resource_group_name 	= "${azurerm_resource_group.rg-terraform-east.name}"
	virtual_network_name 	= "${azurerm_virtual_network.production-network.name}"
	address_prefix 				= "10.1.1.0/24"
}

resource "azurerm_network_interface" "test" {
  name = "VNetInterface1"
	location 						= "${azurerm_resource_group.rg-terraform-east.location}"
	resource_group_name = "${azurerm_resource_group.rg-terraform-east.name}"

	ip_configuration {
		name = "TestConfiguration1"
		subnet_id = "${azurerm_subnet.YYZ.id}"
		private_ip_address_allocation = "static"
		private_ip_address = "10.1.1.25"
	}
}
