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

############################################################

resource "azurerm_resource_group" "rg" {
name = "pawan"
location = "centralindia" 
}

resource "azurerm_virtual_network" "vn" {
    name = "vn"
    location = "centralindia"
    resource_group_name = "pawan"
    address_space = ["10.0.0.0/16"]
  
}
resource "azurerm_subnet" "sub" {
name ="sub"
resource_group_name = "pawan"
virtual_network_name = "vn"
address_prefixes = ["10.0.2.0/24"]  
}
resource "azurerm_network_interface" "niic" {
    name = "niic"
    location = "centralindia"
    resource_group_name = "pawan"
    depends_on = [ azurerm_virtual_network.vn ]
    ip_configuration {
      name = "ip"
      private_ip_address_allocation = "Dynamic"
      subnet_id = data.azurerm_subnet.name.id
    }
}

data "azurerm_subnet" "name" {
  name = "sub"
  resource_group_name = "pawan"
  virtual_network_name = "vn"
  depends_on = [ azurerm_subnet.sub ]
}
data "azurerm_network_interface" "name" {
    name = "niic"
    resource_group_name = "pawan"
  depends_on = [ azurerm_network_interface.niic ]
}

data "azurerm_key_vault" "kivi" {
    name = "keyvoultpawan"
    resource_group_name = "pawan"
}
data "azurerm_key_vault_secret" "kivi1" {
  name = "okgoogle"
  key_vault_id = data.azurerm_key_vault.kivi.id
}
resource "azurerm_virtual_machine" "main" {
  name                  = "vm"
  location              = "centralindia"
  resource_group_name   = "pawan"
  network_interface_ids = [data.azurerm_network_interface.name.id]
  vm_size               = "Standard_DS1_v2"
  depends_on = [ azurerm_network_interface.niic ]

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
    admin_password = data.azurerm_key_vault_secret.kivi1.value
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
