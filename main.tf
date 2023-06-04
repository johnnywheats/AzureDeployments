# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.90.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "VM_RG"
  location = "eastus"
}

resource "azurerm_resource_group" "network" {
  name     = "Network_RG"
  location = "eastus"
}


resource "azurerm_virtual_network" "network" {
  name                = "network-eastus"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "network" {
  name                 = "subnet-eastus"
  virtual_network_name = azurerm_virtual_network.network.name
  resource_group_name  = azurerm_resource_group.network.name
  address_prefixes        = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "internal" {
  name                = "Win2022-nic-eastus"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.network.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_windows_virtual_machine" "main" {
  name                = "Win2022"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "standard_B1s"
  admin_username      = "john"
  admin_password      = "K@l@$hAK4774"

  network_interface_ids = [
    azurerm_network_interface.internal.id
  ]

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
   source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}



