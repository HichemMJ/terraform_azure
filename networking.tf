resource "azurerm_virtual_network" "vnet" {
  name = "vnet"
  address_space = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "internal" {
  name = "internal"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = var.resource_group_name

  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name = "example-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_security_group" "nsg" {
  name ="example-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AppOnPort5000"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
 network_interface_id = azurerm_network_interface.nic.id
 network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "lb-pubip" {
  name = "example-lb-pubip"

  resource_group_name = var.resource_group_name
  location = var.location

  allocation_method = "Static"

  domain_name_label = "${var.resource_group_name}terraformdns"
}

resource "azurerm_lb" "example_lb" {
  name = "example-lb"

  resource_group_name = var.resource_group_name
  location = var.location

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb-pubip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backendpool" {
  loadbalancer_id = azurerm_lb.example_lb.id
  name = "backendAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "name" {
  network_interface_id = azurerm_network_interface.nic.id
  ip_configuration_name = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpool.id
}

resource "azurerm_lb_rule" "lb_rule_5000" {
  name = "Port5000Access"
  loadbalancer_id = azurerm_lb.example_lb.id
  protocol = "Tcp"
  frontend_port = 5000
  backend_port = 5000
  frontend_ip_configuration_name = azurerm_lb.example_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
}
