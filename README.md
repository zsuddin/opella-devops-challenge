# Opella DevOps Challenge - Azure Infrastructure

## Overview

This project provisions a complete Azure infrastructure for the Opella development environment using Terraform. The infrastructure includes a Linux virtual machine with automatically generated SSH keys stored securely in Azure Key Vault, along with all necessary networking components.

## Architecture

### Infrastructure Components

- **Virtual Machine**: Ubuntu 20.04 LTS with Standard_B1ls size
- **Key Vault**: Stores automatically generated SSH keys
- **Virtual Network**: Custom VNet with dedicated subnet
- **Network Security Group**: SSH access rules
- **Public IP**: Static IP for external access
- **Network Interface**: Connects VM to VNet with public IP

### Key Features

- 🔐 **Automatic SSH Key Generation**: Uses Terraform TLS provider to generate 4096-bit RSA keys
- 🛡️ **Secure Key Storage**: SSH keys stored in Azure Key Vault with proper access controls
- 🌐 **Complete Networking**: VNet, subnet, NSG, and public IP configuration
- 🚀 **CI/CD Ready**: GitHub Actions workflows for deployment and destruction
- 📁 **Modular Design**: Reusable VNet module for scalability

## Project Structure

```
opella-devops-challenge/
├── main.tf                    # Main infrastructure configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Provider versions and requirements
├── providers.tf               # Provider configuration
├── backend.tf                 # Remote state configuration
├── tf-state.tf               # State storage resources (commented)
├── environments/
│   ├── dev.tfvars            # Development environment variables
│   └── dev.backend           # Development backend configuration
├── modules/
│   └── vnet/                 # Virtual Network module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── .github/
    └── workflows/
        ├── infra-dev.yml     # Infrastructure deployment workflow
        └── destroy-infra-dev.yml # Infrastructure destruction workflow
```

## Prerequisites

### Required Tools

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for local development)
- Azure subscription with appropriate permissions

### Required Azure Permissions

- Contributor role on the target subscription
- Ability to create resource groups, VMs, Key Vaults, and networking resources

## Setup Instructions

### 1. Azure Service Principal Setup (for CI/CD)

```bash
# Log in to Azure CLI
az login

# Create a Resource Group for the Service Principal
az group create --name "rg-github-actions-sp" --location "eastus"

# Create a Service Principal with Contributor role on your subscription
# Replace <YOUR_SUBSCRIPTION_ID> with your actual Azure Subscription ID
az ad sp create-for-rbac --name "github-actions-sp" --role "Contributor" \
  --scopes "/subscriptions/<SUBSCRIPTION_ID>" --json-auth
```

The output will include:

```json
{
  "clientId": "...",         # Used as AZURE_CLIENT_ID
  "clientSecret": "...",     # Used as AZURE_CLIENT_SECRET
  "subscriptionId": "...",   # Used as AZURE_SUBSCRIPTION_ID
  "tenantId": "..."          # Used as AZURE_TENANT_ID
}
```

### 2. GitHub Secrets Configuration

Add the following secrets to your GitHub repository (`Settings > Secrets and variables > Actions`):

| Secret Name           | Description                     | Value Source                                     |
| --------------------- | ------------------------------- | ------------------------------------------------ |
| `M_AZURE_CREDENTIALS` | Complete Azure credentials JSON | Full JSON output from service principal creation |

### 3. Environment Configuration

Update the environment-specific configuration in `environments/dev.tfvars`:

```hcl
environment         = "dev"
location            = "eastus"
location_short      = "eus"
resource_group_name = "rg-opella-dev-eastus"
subscription_id     = "your-subscription-id-here"
```

## Deployment Methods

#### Infrastructure Deployment

1. Navigate to your repository's **Actions** tab
2. Select the **"infra-dev"** workflow
3. Click **"Run workflow"**
4. The workflow will:
   - Initialize Terraform
   - Plan the infrastructure changes
   - Apply the changes automatically

#### Infrastructure Destruction

1. Navigate to your repository's **Actions** tab
2. Select the **"destroy-infra-dev"** workflow
3. Click **"Run workflow"**
4. **Type "DESTROY"** in the confirmation field
5. Review the destruction plan in the workflow logs
6. Approve the destruction via the GitHub issue created
7. Infrastructure will be destroyed after approval

### Retrieving SSH Keys

#### Azure Portal (GUI)

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Search for "Key vaults" and select your vault (`opella-dev-kv-[random-suffix]`)
3. Go to **Settings > Access policies** and add your user account if not already added
4. Go to **Settings > Secrets**
5. Click on `opella-vm-private-key`
6. Click **"Show Secret Value"** and copy the content
7. Save to a file with proper permissions:

   ```bash
   # Save the private key to a file
   nano vm_private_key.pem
   # Paste the key content and save

   # Set proper permissions
   chmod 600 vm_private_key.pem
   ```

### SSH Connection

```bash
# Using the retrieved private key
ssh -i vm_private_key.pem opella_admin@<VM_PUBLIC_IP>

# Example with actual IP
ssh -i vm_private_key.pem opella_admin@20.124.123.45
```

## Security Features

### Key Management

- **Automatic Generation**: SSH keys are generated using Terraform's TLS provider
- **Secure Storage**: Keys stored in Azure Key Vault with encryption at rest
- **Access Control**: Key Vault access policies control who can retrieve keys
- **Audit Trail**: All key access is logged and auditable

### Network Security

- **Network Security Group**: Controls inbound/outbound traffic
- **SSH-only Access**: Only SSH (port 22) is allowed for remote access
- **Public IP**: Static IP for consistent access

### Infrastructure Security

- **Resource Tagging**: All resources tagged for organization and cost tracking
- **Standard Storage**: Uses Standard LRS for cost-effective storage
- **Soft Delete**: Key Vault soft delete enabled for accidental deletion protection

## Resource Naming Convention

All resources follow a consistent naming pattern:

- **Project**: `opella`
- **Environment**: `dev`
- **Location**: `eastus` (short: `eus`)
- **Pattern**: `{project}-{component}-{environment}-{location}`

Examples:

- VM: `opella-vm`
- Key Vault: `opella-dev-kv-{random-suffix}`
- VNet: `dev-eus-vnet`
- Resource Group: `rg-opella-dev-eastus`
