# Network Interface pour la VM
resource "azurerm_network_interface" "main" {
  name                = "nic-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Windows Server 2022 Virtual Machine
resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  # Image Windows Server 2022 Datacenter Azure Edition
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  # Configuration du disque OS avec chiffrement
  os_disk {
    name                 = "osdisk-${var.project_name}-${var.environment}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 127
  }

  # Désactiver le boot diagnostics (économie de stockage)
  boot_diagnostics {
    storage_account_uri = null
  }

  # Configuration de sécurité moderne
  secure_boot_enabled = true
  vtpm_enabled        = true

  # Identité managée système pour accès sécurisé aux services Azure
  identity {
    type = "SystemAssigned"
  }
}

# Extension pour configurer WinRM (gestion PowerShell à distance)
resource "azurerm_virtual_machine_extension" "winrm" {
  name                       = "winrm-extension"
  virtual_machine_id         = azurerm_windows_virtual_machine.main.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Enable-PSRemoting -Force; Set-Item WSMan:\\localhost\\Service\\Auth\\Basic -Value $true; Set-Item WSMan:\\localhost\\Service\\AllowUnencrypted -Value $true\""
    }
SETTINGS

  tags = var.tags
}

# Extension Azure Monitor Agent (optionnel - pour monitoring)
resource "azurerm_virtual_machine_extension" "azure_monitor" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.main.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  tags = var.tags

  depends_on = [azurerm_virtual_machine_extension.winrm]
}