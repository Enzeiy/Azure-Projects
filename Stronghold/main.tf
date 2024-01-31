terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "stronghold_rg" {
  name     = "stronghold-resourcecs"
  location = "Southeast Asia"
  tags = {
    environemnt = "dev"
  }
}

//Virtual Network for Region 1 Southeast Asia
resource "azurerm_virtual_network" "vnet_SEA_R1" {
  name                = "vnet_r1"
  resource_group_name = azurerm_resource_group.stronghold_rg.name
  location            = azurerm_resource_group.stronghold_rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environemnt = "dev"
  }
}

//Virtual Network for Region 2 East Asia
resource "azurerm_virtual_network" "vnet_EA_R2" {
  name                = "vnet_r2"
  resource_group_name = azurerm_resource_group.stronghold_rg.name
  location            = "East Asia"
  address_space       = ["11.0.0.0/16"]

  tags = {
    environemnt = "dev"
  }
}

//Virtual Network Region 1 SEA subnet
resource "azurerm_subnet" "Subnet_SEA_R1" {
  name                 = "subnet_sea"
  resource_group_name  = azurerm_resource_group.stronghold_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_SEA_R1.name
  address_prefixes     = ["10.1.0.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet_SEA_R1
  ]
}

//Virtual Network Region 2 EA subnet
resource "azurerm_subnet" "Subnet_EA_R2" {
  name                 = "subnet_ea"
  resource_group_name  = azurerm_resource_group.stronghold_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_EA_R2.name
  address_prefixes     = ["11.1.0.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet_SEA_R1
  ]
}

//Network Interface Card (NIC) VM1 Region 1 SEA
resource "azurerm_network_interface" "vm1_nic_r1" {
  name                = "vm1_nic1_r1"
  location            = azurerm_resource_group.stronghold_rg.location
  resource_group_name = azurerm_resource_group.stronghold_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet_SEA_R1.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.vnet_SEA_R1,
    azurerm_subnet.Subnet_SEA_R1
  ]
}

//Network Interface Card (NIC) VM2 Region 1 SEA
resource "azurerm_network_interface" "vm2_nic_r1" {
  name                = "vm2_nic2_r1"
  location            = azurerm_resource_group.stronghold_rg.location
  resource_group_name = azurerm_resource_group.stronghold_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet_SEA_R1.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.vnet_SEA_R1,
    azurerm_subnet.Subnet_SEA_R1
  ]
}

//Network Interface Card (NIC) VM1 Region 2 EA
resource "azurerm_network_interface" "vm1_nic_r2" {
  name                = "vm1_nic1_r2"
  location            = azurerm_virtual_network.vnet_EA_R2.location
  resource_group_name = azurerm_resource_group.stronghold_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet_EA_R2.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.vnet_EA_R2,
    azurerm_subnet.Subnet_EA_R2
  ]
}

//Network Interface Card (NIC) VM2 Region 2 EA
resource "azurerm_network_interface" "vm2_nic_r2" {
  name                = "vm2_nic1_r2"
  location            = azurerm_virtual_network.vnet_EA_R2.location
  resource_group_name = azurerm_resource_group.stronghold_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet_EA_R2.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.vnet_EA_R2,
    azurerm_subnet.Subnet_EA_R2
  ]
}

//Availability Set Region 1 SEA
resource "azurerm_availability_set" "avset_SEA_R1" {
  name                         = "avset_SEA"
  location                     = azurerm_resource_group.stronghold_rg.location
  resource_group_name          = azurerm_resource_group.stronghold_rg.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  depends_on = [
    azurerm_resource_group.stronghold_rg
  ]
}

//Availability Set Region 2 EA
resource "azurerm_availability_set" "avset_EA_R2" {
  name                         = "avset_EA"
  location                     = azurerm_virtual_network.vnet_EA_R2.location
  resource_group_name          = azurerm_resource_group.stronghold_rg.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  depends_on = [
    azurerm_resource_group.stronghold_rg
  ]
}

//Virtual Machine 1 Region 1 SEA
resource "azurerm_windows_virtual_machine" "vm1_SEA_R1" {
  name                = "vm1_r1"
  resource_group_name = azurerm_resource_group.stronghold_rg.name
  location            = azurerm_resource_group.stronghold_rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
  availability_set_id = azurerm_availability_set.avset_SEA_R1.id
  network_interface_ids = [
    azurerm_network_interface.vm1_nic_r1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.vm1_nic_r1,
    azurerm_availability_set.avset_SEA_R1
  ]
}

//Virtual Machine 2 Region 1 SEA
resource "azurerm_windows_virtual_machine" "vm2_SEA_R1" {
  name                = "vm2_r1"
  resource_group_name = azurerm_resource_group.stronghold_rg.name
  location            = azurerm_resource_group.stronghold_rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
  availability_set_id = azurerm_availability_set.avset_SEA_R1.id
  network_interface_ids = [
    azurerm_network_interface.vm2_nic_r1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.vm2_nic_r1,
    azurerm_availability_set.avset_SEA_R1
  ]
}

//Virtual Machine 1 Region 2 EA
resource "azurerm_windows_virtual_machine" "vm1_EA_R2" {
  name                = "vm1_r2"
  resource_group_name = azurerm_resource_group.stronghold_rg.name
  location            = azurerm_virtual_network.vnet_EA_R2.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
  availability_set_id = azurerm_availability_set.avset_EA_R2.id
  network_interface_ids = [
    azurerm_network_interface.vm1_nic_r2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.vm1_nic_r2,
    azurerm_availability_set.avset_EA_R2
  ]
}

//Virtual Machine 1 Region 2 EA
resource "azurerm_windows_virtual_machine" "vm2_EA_R2" {
  name                = "vm2_r2"
  resource_group_name = azurerm_resource_group.stronghold_rg.name
  location            = azurerm_virtual_network.vnet_EA_R2.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
  availability_set_id = azurerm_availability_set.avset_EA_R2.id
  network_interface_ids = [
    azurerm_network_interface.vm2_nic_r2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.vm2_nic_r2,
    azurerm_availability_set.avset_EA_R2
  ]
}

//Network Security Group Region 1 SEA
resource "azurerm_network_security_group" "NSG_SEA_R1" {
    name = "nsg_r1"
    resource_group_name = azurerm_resource_group.stronghold_rg.name
    location = azurerm_resource_group.stronghold_rg.location

    security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


//Network Security Group Region 2 EA
resource "azurerm_network_security_group" "NSG_EA_R2" {
    name = "nsg_r2"
    resource_group_name = azurerm_resource_group.stronghold_rg.name
    location = azurerm_virtual_network.vnet_EA_R2.location

    security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
