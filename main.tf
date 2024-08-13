terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.115.0"
    }
  }
}
provider "azurerm" {
  features {
    
  }
  
}

####################################################################
resource "azurerm_resource_group" "rg" {
  name = "pawan1"
  location = "centralindia"
  
}

########################################################################
resource "azurerm_virtual_network" "vn" {
  name = "vn5"
  location = "centralindia"
  resource_group_name = "pawan1"
  address_space = ["10.0.0.0/16"]
  depends_on = [ azurerm_resource_group.rg ]

}

#############################################################################
resource "azurerm_subnet" "subb" {
  name = "subb1"
  resource_group_name = "pawan1"
  virtual_network_name = "vn5"
  address_prefixes = ["10.0.2.0/24"]
  depends_on = [ azurerm_resource_group.rg, azurerm_virtual_network.vn ]
}

###############################################################################
resource "azurerm_network_interface" "niic" {
  name = "nic_pawan"
  resource_group_name = "pawan1"
  location = "centralindia"
  depends_on = [ azurerm_resource_group.rg , azurerm_virtual_network.vn ]
  ip_configuration {
    name = "niiic"
    subnet_id = data.azurerm_subnet.subbb.id
    private_ip_address_allocation = "Dynamic"
  }
  
}
data "azurerm_subnet" "subbb" {
  name = "subb1"
  resource_group_name = "pawan1"  
  virtual_network_name = "vn5"
  depends_on = [ azurerm_subnet.subb ]
}

###################################################################################

resource "azurerm_virtual_machine" "vm22" {
 name                  = "pawan_vm"
  location              = "centralindia"
  resource_group_name   = "pawan1"
  network_interface_ids = [ data.azurerm_network_interface.ok.id ]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
data "azurerm_network_interface" "ok" {
  name = "nic_pawan"
  resource_group_name = "pawan1"
}
