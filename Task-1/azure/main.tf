# ── RESOURCE GROUP ────────────────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = "capstone-rg"
  location = var.location
}

# ── VIRTUAL NETWORK ───────────────────────────────────
resource "azurerm_virtual_network" "vnet" {
  name                = "capstone-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "capstone-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# ── NSG ───────────────────────────────────────────────
resource "azurerm_network_security_group" "nsg" {
  name                = "capstone-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ── PUBLIC IP ─────────────────────────────────────────
resource "azurerm_public_ip" "pip" {
  name                = "capstone-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# ── NIC ───────────────────────────────────────────────
resource "azurerm_network_interface" "nic" {
  name                = "capstone-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ── VIRTUAL MACHINE ───────────────────────────────────
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "capstone-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B1ms"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
