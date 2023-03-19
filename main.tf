# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

variable "prefix" {
  default     = "lab002"
  type        = string
  description = "The prefix used for the resource group and resources."
}

variable "admin_username" {
  default   = "azureuser"
  type      = string
  sensitive = true
}
variable "admin_password" {
  type      = string
  sensitive = true
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}rg"
  location = "australiaeast"
  tags = {
    environment = "dev"
    customer    = "paradoxus"
    product     = "AD lab - Terraform"
    team        = "DevOps"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "ip" {
  name                = "${var.prefix}publicip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  security_rule {
    name                       = "allow_rdp"
    priority                   = 1001
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Inbound"
    destination_address_prefix = "*"
    destination_port_range     = 3389
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
  security_rule {
    name                       = "allow_web_traffic"
    priority                   = 1002
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Inbound"
    destination_address_prefix = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
  security_rule {
    name                       = "allow_powershell_remoting"
    priority                   = 1003
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Inbound"
    destination_address_prefix = "*"
    destination_port_range     = "5985-5986"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.subnet.id
    public_ip_address_id          = azurerm_public_ip.ip.id
    primary                       = true
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.prefix}vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  vm_size               = "Standard_DS3_v2" # Standard_DS1_v2, too small
  network_interface_ids = [azurerm_network_interface.nic.id]
  storage_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.prefix}vmdisk"
    os_type           = "Windows"
    managed_disk_type = "Premium_LRS" # StandardSSD_LRS, Standard_LRS
    create_option     = "FromImage"
  }
  os_profile {
    computer_name  = "${var.prefix}vm"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_windows_config {
    winrm {
      protocol = "HTTP" # HTTPS
    }
  }
}
