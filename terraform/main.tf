# Configuration Terraform
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend pour stocker le state (optionnel - à configurer si besoin)
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "tfstatestorage"
  #   container_name       = "tfstate"
  #   key                  = "winserver2022.tfstate"
  # }
}

# Provider Azure
provider "azurerm" {
  features {
    # Activer le soft delete pour les ressources critiques
    key_vault {
      purge_soft_delete_on_destroy = false
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = true
      skip_shutdown_and_force_delete = false
    }
  }
}

# Générer un suffixe aléatoire pour les noms uniques
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group principal
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  location = var.location
  tags     = var.tags
}