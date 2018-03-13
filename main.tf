# Configure the Microsoft Azure Provider
provider "azurerm" {
	subscription_id = "${var.Subscription_ID}"
	tenant_id       = "${var.Tenant_ID}"
}

resource "azurerm_resource_group" "rg-terraform-east" {
	name			= "rg-terraform-east"
	location	= "Canada East"
}

resource "azurerm_network_security_group" "my-security-group" {
	name 								= "my-security-group"
	location 						= "${azurerm_resource_group.rg-terraform-east.location}"
	resource_group_name = "${azurerm_resource_group.rg-terraform-east.name}"
}

resource "azurerm_network_security_rule" "allow-ssh" {
	name 												= "allow SSH"
	priority 										= 100
	direction 									= "Inbound"
	access 											= "Allow"
	protocol 										= "TCP"
	source_port_range 					= "*"
	destination_port_range 			= "22"
	source_address_prefix 			= "*"
	destination_address_prefix 	= "*"
	resource_group_name 				= "${azurerm_resource_group.rg-terraform-east.name}"
  network_security_group_name = "${azurerm_network_security_group.my-security-group.name}"
}

resource "azurerm_network_security_rule" "allow-http" {
	name 												= "allow HTTP"
	priority 										= 110
	direction 									= "Inbound"
	access 											= "Allow"
	protocol 										= "TCP"
	source_port_range 					= "*"
	destination_port_range 			= "80"
	source_address_prefix 			= "*"
	destination_address_prefix 	= "*"
	resource_group_name 				= "${azurerm_resource_group.rg-terraform-east.name}"
  network_security_group_name = "${azurerm_network_security_group.my-security-group.name}"
}

resource "azurerm_network_security_rule" "allow-https" {
	name 												= "allow HTTPS"
	priority 										= 120
	direction 									= "Inbound"
	access 											= "Allow"
	protocol 										= "TCP"
	source_port_range 					= "*"
	destination_port_range 			= "443"
	source_address_prefix 			= "*"
	destination_address_prefix 	= "*"
	resource_group_name 				= "${azurerm_resource_group.rg-terraform-east.name}"
  network_security_group_name = "${azurerm_network_security_group.my-security-group.name}"
}

resource "azurerm_virtual_network" "production-network" {
	name 								= "production-network"
	address_space 			= ["10.1.0.0/16"]
	location 						= "${azurerm_resource_group.rg-terraform-east.location}"
	resource_group_name = "${azurerm_resource_group.rg-terraform-east.name}"
}

resource "azurerm_subnet" "prod-subnet" {
	name 											= "prod-subnet"
	resource_group_name 			= "${azurerm_resource_group.rg-terraform-east.name}"
	virtual_network_name 			= "${azurerm_virtual_network.production-network.name}"
	address_prefix 			  		= "10.1.1.0/24"
	network_security_group_id = "${azurerm_network_security_group.my-security-group.id}"
}

resource "azurerm_network_interface" "docker-ubuntu-server-nic" {
  name = "docker-ubuntu-server-nic"
	location 									= "${azurerm_resource_group.rg-terraform-east.location}"
	resource_group_name 			= "${azurerm_resource_group.rg-terraform-east.name}"
	network_security_group_id = "${azurerm_network_security_group.my-security-group.id}"

	ip_configuration {
		name 													= "docker-ubuntu-server-nic-config"
		subnet_id 										= "${azurerm_subnet.prod-subnet.id}"
		private_ip_address_allocation = "static"
		private_ip_address 						= "10.1.1.25"
		public_ip_address_id 					= "${azurerm_public_ip.ubuntu-server.id}"
	}
}

resource "azurerm_public_ip" "docker-ubuntu-server" {
	name = "docker-ubuntu-server-ip"
	location 										 = "${azurerm_resource_group.rg-terraform-east.location}"
	resource_group_name 				 = "${azurerm_resource_group.rg-terraform-east.name}"
	public_ip_address_allocation = "dynamic"
	domain_name_label 					 = "docker-ubuntu-server"
}
