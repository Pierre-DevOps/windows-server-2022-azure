# Variables globales
variable "project_name" {
  description = "Nom du projet pour le nommage des ressources"
  type        = string
  default     = "winserver2022"
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Région Azure pour le déploiement"
  type        = string
  default     = "switzerlandnorth"
}

# Réseau
variable "vnet_address_space" {
  description = "Plage d'adresses du Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_vm_prefix" {
  description = "Plage d'adresses du subnet pour les VMs"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "subnet_bastion_prefix" {
  description = "Plage d'adresses du subnet Azure Bastion (minimum /27 requis)"
  type        = list(string)
  default     = ["10.0.2.0/27"]
}

# VM Configuration
variable "vm_size" {
  description = "Taille de la VM"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Nom d'utilisateur administrateur de la VM"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Mot de passe administrateur de la VM"
  type        = string
  sensitive   = true
}

# Tags
variable "tags" {
  description = "Tags à appliquer aux ressources"
  type        = map(string)
  default = {
    Project     = "Windows Server 2022"
    ManagedBy   = "Terraform"
    Environment = "Production"
    Owner       = "Pierre"
    DeployedBy  = "GitHub-Actions"
  }
}