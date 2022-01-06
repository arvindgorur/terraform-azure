resource "azurerm_resource_group" "remote_dev_env" {
  name     = "remote-dev-env"
  location = "Canada Central"
  tags = {
    "Purpose" = "Development"
  }
}

resource "azurerm_virtual_network" "remote_dev_env_vnet" {
  name                = "vnet-canada-central"
  resource_group_name = azurerm_resource_group.remote_dev_env.name
  location            = azurerm_resource_group.remote_dev_env.location
  address_space       = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "default_subnet" {
  name                 = "canada-central"
  resource_group_name  = azurerm_resource_group.remote_dev_env.name
  virtual_network_name = azurerm_virtual_network.remote_dev_env_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main_nsg" {
  name                = "main-nsg"
  location            = azurerm_resource_group.remote_dev_env.location
  resource_group_name = azurerm_resource_group.remote_dev_env.name

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

resource "azurerm_public_ip" "public_ip" {
  name                = "dev-vm-public-ip"
  location            = azurerm_resource_group.remote_dev_env.location
  resource_group_name = azurerm_resource_group.remote_dev_env.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main_nic" {
  name                = "dev-vm-nic-1"
  location            = azurerm_resource_group.remote_dev_env.location
  resource_group_name = azurerm_resource_group.remote_dev_env.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.25"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "dev_vm_nic_sg_association" {
  network_interface_id      = azurerm_network_interface.main_nic.id
  network_security_group_id = azurerm_network_security_group.main_nsg.id
}

resource "azurerm_linux_virtual_machine" "dev_vm" {
  name                = "dev-vm"
  location            = azurerm_resource_group.remote_dev_env.location
  resource_group_name = azurerm_resource_group.remote_dev_env.name
  size                = "Standard_DS1_v2"
  admin_username      = "arvindgorur"
  network_interface_ids = [
    azurerm_network_interface.main_nic.id,
  ]

  admin_ssh_key {
    username   = "arvindgorur"
    public_key = file("./public-ssh-keys/remote-dev-env-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    name                 = "dev-vm-os-disk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = {
    "Purpose" = "Development"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_schedule" {
  virtual_machine_id    = azurerm_linux_virtual_machine.dev_vm.id
  location              = azurerm_resource_group.remote_dev_env.location
  enabled               = true
  daily_recurrence_time = "1700"
  timezone              = "Eastern Standard Time"
  notification_settings {
    enabled = false
  }
}