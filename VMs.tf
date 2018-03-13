resource "azurerm_virtual_machine" "docker-ubuntu" {
  name 								  = "docker-ubuntu"
	location 						  = "${azurerm_resource_group.rg-terraform-east.location}"
	resource_group_name   = "${azurerm_resource_group.rg-terraform-east.name}"
  network_interface_ids = ["${azurerm_network_interface.ubuntu-server-nic.id}"]
	vm_size 						  = "Standard_A1"

	#delete_on_termination = true
	#delete_data_disks_on_termination = true

	storage_image_reference {
		publisher = "Canonical"
		offer 		= "UbuntuServer"
		sku 			= "16.04-LTS"
		version 	= "latest"
	}

  storage_os_disk {
    name = "docker-ubuntu-os"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "docker-ubuntu"
    admin_username = "arvindgorur"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/arvindgorur/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrXptbJa4DVMP046NDT5vM+rdLtM/WO9lap5OzhRnSReMS+THIvpBhOS1dpH5LQYMpNb/Cvs4uBao596cuXWieL8JBkqRR9qDhvlJv22p7wNfh9ynJ1bE5siSWmtUucyAuRMl4hf2u38ZKwp0K6SdsN8TdvgydX+Ze+4bZgHhS+LKLi0g+HrOhHKVutdEPsdz842wtgBlPygVCCIDMLCnvj2MFZ7Cm48fb39uMCHVr88Cgspgj6CgehS78qNo36wXC8s195EReaPZKz+TxfUMktVnm6dPY+4t42xcvlJNcaTJZ703dr32McedQtgb0aYeMeUMH/ohcC2U3ScILmIiT imported-openssh-key"
    }
  }
}

resource "azurerm_virtual_machine" "kubernetes-ubuntu" {

}
