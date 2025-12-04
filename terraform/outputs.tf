# Outputs pour récupérer les informations importantes après déploiement
output "resource_group_name" {
  description = "Nom du Resource Group créé"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Région Azure du déploiement"
  value       = azurerm_resource_group.main.location
}

output "vnet_name" {
  description = "Nom du Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "vm_name" {
  description = "Nom de la VM Windows Server 2022"
  value       = azurerm_windows_virtual_machine.main.name
}

output "vm_id" {
  description = "ID Azure de la VM"
  value       = azurerm_windows_virtual_machine.main.id
}

output "vm_private_ip" {
  description = "Adresse IP privée de la VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "admin_username" {
  description = "Nom d'utilisateur administrateur"
  value       = var.admin_username
}

output "bastion_name" {
  description = "Nom du Azure Bastion Host"
  value       = azurerm_bastion_host.main.name
}

output "bastion_public_ip" {
  description = "Adresse IP publique du Bastion"
  value       = azurerm_public_ip.bastion.ip_address
}

output "nsg_name" {
  description = "Nom du Network Security Group"
  value       = azurerm_network_security_group.vm.name
}

output "vm_identity_principal_id" {
  description = "Principal ID de l'identité managée de la VM"
  value       = azurerm_windows_virtual_machine.main.identity[0].principal_id
}

output "connection_instructions" {
  description = "Instructions pour se connecter à la VM"
  value       = <<-EOT
    
                 CONNEXION À LA VM VIA AZURE BASTION                        
    
    
    1. Accéder au portail Azure:
       https://portal.azure.com
    
    2. Rechercher la VM: ${azurerm_windows_virtual_machine.main.name}
    
    3. Cliquer sur "Connect" → "Bastion"
    
    4. Utiliser les identifiants:
       • Username: ${var.admin_username}
       • Password: (celui configuré dans VM_ADMIN_PASSWORD)
    
    5. Informations réseau:
       • IP Privée: ${azurerm_network_interface.main.private_ip_address}
       • VNet: ${azurerm_virtual_network.main.name}
       • Subnet: ${azurerm_subnet.vm.name}
    
    
           SÉCURITÉ                                 
    
    
    ✓ Pas d'IP publique sur la VM
    ✓ Connexion uniquement via Azure Bastion
    ✓ NSG restrictif (RDP autorisé seulement depuis Bastion)
    ✓ Secure Boot et vTPM activés
    ✓ Managed Identity configurée
    ✓ Azure Monitor Agent installé
    
  EOT
}