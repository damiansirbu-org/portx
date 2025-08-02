# Azure CLI Package Manual

## Package Information
- **Package Name**: azure-cli
- **Category**: Cloud
- **Type**: Microsoft Azure CLI
- **License**: MIT

## Description
Microsoft Azure Command Line Interface - cross-platform tool for managing Azure resources.

Provides comprehensive access to Azure services through command-line interface with support for scripting, automation, and interactive resource management.
Includes Python runtime and all Azure service modules for complete cloud operations.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| az | Microsoft Azure command line interface | Manage all Azure services and resources |
| python.exe | Python runtime for Azure CLI | Bundled Python interpreter |
| pythonw.exe | Python runtime (windowed) | Windows Python interpreter |

## Supported Azure Services
- **Compute**: Virtual Machines, App Service, Container Instances, Kubernetes Service
- **Storage**: Blob Storage, File Storage, Queue Storage, Table Storage
- **Database**: SQL Database, Cosmos DB, MySQL, PostgreSQL
- **Networking**: Virtual Networks, Load Balancer, Application Gateway, DNS
- **Security**: Key Vault, Security Center, Active Directory
- **Monitoring**: Monitor, Log Analytics, Application Insights
- **DevOps**: DevOps Services, Container Registry, Resource Manager
- **AI/ML**: Cognitive Services, Machine Learning, Bot Service
- **And 100+ other Azure services**

## Common Usage Examples

### Authentication and Configuration
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "subscription-name"

# List available subscriptions
az account list --output table
```

### Resource Management
```bash
# Create resource group
az group create --name myResourceGroup --location eastus

# List resource groups
az group list --output table

# Delete resource group
az group delete --name myResourceGroup --yes --no-wait
```

### Virtual Machine Operations
```bash
# Create VM
az vm create --resource-group myResourceGroup --name myVM --image UbuntuLTS --admin-username azureuser --generate-ssh-keys

# List VMs
az vm list --output table

# Start/stop VM
az vm start --resource-group myResourceGroup --name myVM
az vm stop --resource-group myResourceGroup --name myVM
```

### Storage Operations
```bash
# Create storage account
az storage account create --name mystorageaccount --resource-group myResourceGroup --location eastus --sku Standard_LRS

# Upload blob
az storage blob upload --account-name mystorageaccount --container-name mycontainer --name myblob --file localfile.txt

# List blobs
az storage blob list --account-name mystorageaccount --container-name mycontainer --output table
```

### Kubernetes Service (AKS)
```bash
# Create AKS cluster
az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

# Browse AKS dashboard
az aks browse --resource-group myResourceGroup --name myAKSCluster
```

## Output Formats
Azure CLI supports multiple output formats:
```bash
# Table format (human-readable)
az vm list --output table

# JSON format (default)
az vm list --output json

# YAML format
az vm list --output yaml

# Query specific fields
az vm list --query "[].{Name:name, ResourceGroup:resourceGroup}" --output table
```

## Installation
Complete Azure CLI v2 with Python runtime and all Azure service modules.
Ready for enterprise cloud operations, automation, and resource management.

## Dependencies
- Python runtime (bundled)
- Azure subscription and credentials
- Network access for Azure API calls

## Configuration
Run `az login` to authenticate, then:
- Set default subscription with `az account set`
- Configure default location with `az configure`
- Set output format preferences

---
*Part of PORTX Portable Development Environment*