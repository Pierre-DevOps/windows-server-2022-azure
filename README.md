# Windows Server 2022 - Déploiement Sécurisé sur Azure

Projet de déploiement automatisé d'un serveur Windows Server 2022 sur Azure avec Infrastructure as Code (Terraform) et CI/CD (GitHub Actions).

## Table des matières

- Vue d'ensemble
- Architecture
- Fonctionnalités
- Prérequis
- Installation
- Utilisation
- Sécurité
- Structure du projet
- Configuration
- CI/CD
- Coûts estimés
- Dépannage
- Auteur

## Vue d'ensemble

Ce projet déploie automatiquement une infrastructure Azure complète et sécurisée comprenant :

- Windows Server 2022 Datacenter Azure Edition
- Azure Bastion pour connexion RDP sécurisée (pas d'IP publique sur la VM)
- Network Security Groups (NSG) avec règles restrictives
- Virtual Network avec architecture subnet segmentée
- Managed Identity pour accès sécurisé aux services Azure
- Secure Boot et vTPM activés

### Contexte pédagogique

Projet réalisé dans le cadre de la certification Administrateur Système DevOps (RNCP36061) démontrant les compétences suivantes :
- AT1 : Automatisation du déploiement d'infrastructure cloud
- Sécurisation des infrastructures
- Infrastructure as Code avec Terraform
- CI/CD avec GitHub Actions

## Architecture

L'infrastructure déployée comprend :
- Un Resource Group dans la région Switzerland North
- Un Virtual Network avec la plage d'adresses 10.0.0.0/16
- Un subnet pour les VMs (10.0.1.0/24)
- Un subnet pour Azure Bastion (10.0.2.0/27)
- Une VM Windows Server 2022 sans IP publique
- Un Azure Bastion Host avec IP publique pour connexion sécurisée
- Un Network Security Group avec règles restrictives

### Flux de connexion sécurisé

Utilisateur -> Azure Portal (HTTPS) -> Azure Bastion (RDP over TLS) -> VM Windows Server 2022 (pas d'IP publique)

## Fonctionnalités

### Infrastructure

- Windows Server 2022 Datacenter Azure Edition (dernière version)
- VM Size configurable (par défaut: Standard_B2s - 2 vCPU, 4 GB RAM)
- Disque OS : Standard LRS 127 GB
- Chiffrement : Secure Boot et vTPM activés
- Identité managée : System-assigned pour accès Azure services

### Réseau

- Virtual Network : 10.0.0.0/16
- Subnet VM : 10.0.1.0/24
- Subnet Bastion : 10.0.2.0/27 (requis par Azure)
- Pas d'IP publique sur la VM (connexion via Bastion uniquement)

### Sécurité

- Azure Bastion : Connexion RDP sécurisée sans exposition Internet
- NSG restrictif avec règles :
  - RDP (3389) autorisé uniquement depuis Bastion
  - WinRM (5985/5986) autorisé uniquement depuis Bastion
  - Tout le reste bloqué par défaut
- Pas d'authentification par clé SSH (mot de passe sécurisé via GitHub Secrets)
- Tags pour traçabilité et gouvernance

### Automatisation

- Terraform : Infrastructure as Code versionnée
- GitHub Actions : CI/CD automatique
- Validation automatique : fmt, validate, plan avant apply
- Commentaires PR : Plan Terraform automatiquement affiché
- Workflow manuel : Déclenchement possible via workflow_dispatch

## Prérequis

### Outils nécessaires

- Azure CLI >= 2.50.0
- Terraform >= 1.6.0
- Git
- Compte Azure for Students ou Azure Subscription
- Compte GitHub

### Permissions Azure requises

- Contributor sur la subscription Azure (ou le resource group)
- Droits de création de Service Principal

## Installation

### Etape 1 : Cloner le dépôt
```bash
git clone https://github.com/Pierre-DevOps/windows-server-2022-azure.git
cd windows-server-2022-azure
```

### Etape 2 : Créer le Service Principal Azure
```powershell
az login

az ad sp create-for-rbac --name "github-actions-winserver" --role "Contributor" --scopes /subscriptions/$(az account show --query id -o tsv) --sdk-auth
```

IMPORTANT : Copier tout le JSON retourné

### Etape 3 : Configurer les GitHub Secrets

Aller dans Settings -> Secrets and variables -> Actions et créer ces 6 secrets :

- AZURE_CREDENTIALS : JSON complet du Service Principal
- AZURE_SUBSCRIPTION_ID : subscriptionId du JSON
- AZURE_TENANT_ID : tenantId du JSON
- AZURE_CLIENT_ID : clientId du JSON
- AZURE_CLIENT_SECRET : clientSecret du JSON
- VM_ADMIN_PASSWORD : Mot de passe fort (min 12 caractères avec majuscules, minuscules, chiffres et caractères spéciaux)

## Utilisation

### Déploiement automatique (GitHub Actions)

1. Push sur la branche main :
```bash
git add .
git commit -m "Deploy Windows Server 2022"
git push origin main
```

2. Le workflow GitHub Actions se déclenche automatiquement
3. Consulter l'avancement dans l'onglet Actions sur GitHub
4. Les outputs Terraform s'affichent dans le Summary du workflow

### Déploiement manuel (local)
```bash
cd terraform
terraform init
terraform validate
terraform plan -var="admin_password=VotreMotDePasseSecurisé"
terraform apply -var="admin_password=VotreMotDePasseSecurisé"
```

### Connexion à la VM

1. Aller sur le portail Azure : https://portal.azure.com
2. Rechercher votre VM (nom affiché dans les outputs)
3. Cliquer sur Connect puis Bastion
4. Entrer les identifiants :
   - Username : azureadmin (par défaut)
   - Password : celui configuré dans VM_ADMIN_PASSWORD

### Destruction de l'infrastructure

ATTENTION : Supprime toutes les ressources
```bash
cd terraform
terraform destroy -var="admin_password=VotreMotDePasseSecurisé"
```

## Sécurité

### Mesures de sécurité implémentées

- Pas d'IP publique : VM non exposée sur Internet
- Azure Bastion : Connexion RDP sécurisée via navigateur
- NSG restrictif : Firewall au niveau réseau
- RDP filtré : Autorisé uniquement depuis Bastion subnet
- Secure Boot : Protection contre rootkits/bootkits
- vTPM : Trusted Platform Module virtuel
- Managed Identity : Pas de secrets dans le code
- Secrets GitHub : Credentials chiffrés
- Tags : Traçabilité et gouvernance

### Règles NSG appliquées

INBOUND:
- Priority 100 : Allow RDP (3389) from AzureBastionSubnet
- Priority 110 : Allow WinRM (5985/5986) from AzureBastionSubnet
- Priority 4096 : Deny All

OUTBOUND:
- Priority 100 : Allow All (comportement standard Azure)

## Structure du projet
```
windows-server-2022-azure/
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── network.tf
│   ├── security.tf
│   └── compute.tf
├── .gitignore
└── README.md
```

## Configuration

### Variables Terraform personnalisables

Modifier dans terraform/variables.tf ou créer un fichier terraform.tfvars :
```hcl
project_name = "monprojet"
environment  = "dev"
location     = "switzerlandnorth"
vm_size      = "Standard_B2s"
admin_username = "myadmin"

tags = {
  Project     = "Mon Projet"
  Owner       = "Votre Nom"
  Environment = "Development"
}
```

## CI/CD

### Workflow GitHub Actions

Le workflow .github/workflows/terraform-deploy.yml s'exécute sur :

1. Push sur main avec modifications dans terraform/ : Déploiement automatique
2. Pull Request : Plan Terraform affiché en commentaire
3. Déclenchement manuel : Via l'onglet Actions (workflow_dispatch)

## Coûts estimés

### Azure for Students (100 dollars de crédit)

- VM B2s : environ 30 euros par mois (2 vCPU, 4 GB RAM, 24/7)
- Bastion Basic : environ 5 euros par mois
- Disque Standard LRS 127GB : environ 2 euros par mois
- Bande passante : environ 1 euro par mois
- Total : environ 38 euros par mois ou 456 euros par an

## Dépannage

### Erreur : Subscription doesn't exist

Solution : Vérifier que AZURE_SUBSCRIPTION_ID est correct
```bash
az account show --query id -o tsv
```

### Erreur : Service Principal authentication failed

Solutions :
1. Régénérer le Service Principal
2. Vérifier que tous les secrets GitHub sont corrects
3. Vérifier les permissions du SP sur la subscription

### Erreur : VM size not available

Solution : Changer la région ou la taille de VM
```bash
az vm list-sizes --location switzerlandnorth -o table
```

## Auteur

Pierre - Etudiant DevOps

- Formation : Bachelor Administrateur Système DevOps (RNCP36061)
- GitHub : Pierre-DevOps
- Compétences : Terraform, Azure, PowerShell, CI/CD
- Certifications : Azure AZ-900, AZ-104 (en cours)

## Licence

Ce projet est sous licence MIT.

---

Made by Pierre - Projet pédagogique Bachelor DevOps 2025