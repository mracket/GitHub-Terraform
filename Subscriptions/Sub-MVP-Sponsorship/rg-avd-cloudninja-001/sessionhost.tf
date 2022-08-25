data "azurerm_virtual_network" "AVD-vNet" {
  name                = var.avd_vnet
  resource_group_name = var.avd_vnet_resource_group
}

data "azurerm_subnet" "subnets" {
  name                  = var.avd_hostpool_subnet
  virtual_network_name  = data.azurerm_virtual_network.AVD-vNet.name
  resource_group_name   = data.azurerm_virtual_network.AVD-vNet.resource_group_name
 
}

resource "azurerm_network_interface" "main" {
  count               = var.NumberOfSessionHosts
  name                = "nic-${var.vm_prefix}-${format("%02d",count.index+1)}"
  location            = var.avd_Location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.subnets.id
    private_ip_address_allocation = "Dynamic"
  }
}

data "azurerm_key_vault" "kv-cloudninja-avd-002" {
  name                = "kv-cloudninja-avd-002"
  resource_group_name = "rg-keyvault-001"
}

data "azurerm_key_vault_secret" "avd-localadmin" {
  name         = "avd-localadmin"
  key_vault_id = data.azurerm_key_vault.kv-cloudninja-avd-002.id
}

resource "azurerm_windows_virtual_machine" "main" {
  count                 = var.NumberOfSessionHosts
  name                  = "vm-${var.vm_prefix}-${format("%02d",count.index+1)}"
  location            = var.avd_Location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]
  size                  = "Standard_D2s_v3"
  license_type          = "Windows_Client"
  admin_username        = "localadmin"
  admin_password        = data.azurerm_key_vault_secret.avd-localadmin.value

  additional_capabilities {
  }
  identity {
    type = "SystemAssigned"
  }
  source_image_reference {
    offer     = "office-365"
    publisher = "microsoftwindowsdesktop"
    sku       = "win11-21h2-avd-m365"
    version   = "latest"
  }
  os_disk {
    name              = "vm-${var.vm_prefix}-${format("%02d",count.index+1)}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }  
}

resource "azurerm_virtual_machine_extension" "dsc" {
  count = var.NumberOfSessionHosts
  name                 = "AddToAVD"
  virtual_machine_id   = element(azurerm_windows_virtual_machine.main.*.id, count.index)
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.73"    
  auto_upgrade_minor_version = true

  settings           = <<SETTINGS
            {
                "modulesUrl": "${var.avd_agent_location}",
                "configurationFunction": "Configuration.ps1\\AddSessionHost",            
                "properties": {
                    "hostPoolName": "${azurerm_virtual_desktop_host_pool.hostpool.name}",
                    "aadJoin": true,
                    "UseAgentDownloadEndpoint": true,
                    "aadJoinPreview": false,
                    "mdmId": "",
                    "sessionHostConfigurationLastUpdateTime": "",
                    "registrationInfoToken" : "${azurerm_virtual_desktop_host_pool_registration_info.registrationkey.token}" 
                }
            }
            SETTINGS  
  
    depends_on = [
        azurerm_windows_virtual_machine.main
    ]
}

resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
    count = var.NumberOfSessionHosts
    name                              = "AADLoginForWindows"
    virtual_machine_id   = element(azurerm_windows_virtual_machine.main.*.id, count.index)
    publisher                         = "Microsoft.Azure.ActiveDirectory"
    type                              = "AADLoginForWindows"
    type_handler_version              = "1.0"
    auto_upgrade_minor_version        = true
    depends_on = [
        azurerm_virtual_machine_extension.dsc
    ]
}

resource "null_resource" "FSLogix" {
  count = var.NumberOfSessionHosts
  provisioner "local-exec" {
    command = "az vm run-command invoke --command-id RunPowerShellScript --name ${element(azurerm_windows_virtual_machine.main.*.name, count.index)} -g ${azurerm_resource_group.resourcegroup.name} --scripts 'New-ItemProperty -Path HKLM:\\SOFTWARE\\FSLogix\\Profiles -Name VHDLocations -Value \\\\cloudninjafsl11072022.file.core.windows.net\\avdprofiles -PropertyType MultiString;New-ItemProperty -Path HKLM:\\SOFTWARE\\FSLogix\\Profiles -Name Enabled -Value 1 -PropertyType DWORD;New-ItemProperty -Path HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\Kerberos\\Parameters -Name CloudKerberosTicketRetrievalEnabled -Value 1 -PropertyType DWORD;New-Item -Path HKLM:\\Software\\Policies\\Microsoft\\ -Name AzureADAccount;New-ItemProperty -Path HKLM:\\Software\\Policies\\Microsoft\\AzureADAccount  -Name LoadCredKeyFromProfile -Value 1 -PropertyType DWORD;Restart-Computer'"
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = [
       azurerm_virtual_machine_extension.AADLoginForWindows
    ]
}
