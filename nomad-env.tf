resource "azurerm_resource_group" "hashicorp_nomad" {
  name     = "hashicorp_nomad"
  location = "Canada Central"
  tags = {
    "Purpose" = "Nomad"
  }
}

resource "azurerm_virtual_network" "nomad_vnet" {
  name                = "vnet-canada-central"
  resource_group_name = azurerm_resource_group.hashicorp_nomad.name
  location            = azurerm_resource_group.hashicorp_nomad.location
  address_space       = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "nomad_default_subnet" {
  name                 = "canada-central"
  resource_group_name  = azurerm_resource_group.hashicorp_nomad.name
  virtual_network_name = azurerm_virtual_network.nomad_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nomad_main_nsg" {
  name                = "main-nsg"
  location            = azurerm_resource_group.hashicorp_nomad.location
  resource_group_name = azurerm_resource_group.hashicorp_nomad.name

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "nomad_public_ip" {
  name                = "nomad-vm-public-ip"
  location            = azurerm_resource_group.hashicorp_nomad.location
  resource_group_name = azurerm_resource_group.hashicorp_nomad.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nomad_main_nic" {
  name                = "nomad-vm-nic-1"
  location            = azurerm_resource_group.hashicorp_nomad.location
  resource_group_name = azurerm_resource_group.hashicorp_nomad.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.nomad_default_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.25"
    public_ip_address_id          = azurerm_public_ip.nomad_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nomad_vm_nic_sg_association" {
  network_interface_id      = azurerm_network_interface.nomad_main_nic.id
  network_security_group_id = azurerm_network_security_group.nomad_main_nsg.id
}

# resource "azurerm_linux_virtual_machine" "nomad_vm" {
#   name                = "nomad-vm"
#   location            = azurerm_resource_group.hashicorp_nomad.location
#   resource_group_name = azurerm_resource_group.hashicorp_nomad.name
#   size                = "Standard_D2s_v3"
#   admin_username      = "arvindgorur"
#   network_interface_ids = [
#     azurerm_network_interface.nomad_main_nic.id,
#   ]

#   admin_ssh_key {
#     username   = "arvindgorur"
#     public_key = file("./public-ssh-keys/remote-dev-env-key.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "StandardSSD_LRS"
#     name                 = "dev-vm-os-disk"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

#   boot_diagnostics {
#     storage_account_uri = null
#   }

#   tags = {
#     "Purpose" = "Nomad"
#   }
# }

# resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_schedule" {
#   virtual_machine_id    = azurerm_linux_virtual_machine.nomad_vm.id
#   location              = azurerm_resource_group.hashicorp_nomad.location
#   enabled               = true
#   daily_recurrence_time = "1700"
#   timezone              = "Eastern Standard Time"
#   notification_settings {
#     enabled = false
#   }
# }