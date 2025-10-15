#!/bin/bash

# GitHub Actions Pipeline Setup Script
# This script helps set up the necessary Azure resources and GitHub secrets
# for the Terraform Azure Enterprise pipeline

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists az; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command_exists gh; then
        print_warning "GitHub CLI is not installed. You'll need to set secrets manually."
    fi
    
    if ! command_exists jq; then
        print_error "jq is not installed. Please install it first."
        exit 1
    fi
    
    print_success "Prerequisites check completed"
}

# Login to Azure
azure_login() {
    print_status "Checking Azure login status..."
    
    if ! az account show >/dev/null 2>&1; then
        print_status "Please log in to Azure..."
        az login
    fi
    
    # Get current subscription
    SUBSCRIPTION_ID=$(az account show --query id --output tsv)
    SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
    
    print_success "Logged in to Azure subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
}

# Create Terraform state storage
create_terraform_state_storage() {
    print_status "Creating Terraform state storage..."
    
    # Generate unique storage account name
    RANDOM_SUFFIX=$(date +%s | tail -c 6)
    STATE_STORAGE_ACCOUNT="tfstate${RANDOM_SUFFIX}"
    STATE_RESOURCE_GROUP="rg-terraform-state"
    LOCATION="East US 2"
    
    print_status "Creating resource group: $STATE_RESOURCE_GROUP"
    az group create \
        --name "$STATE_RESOURCE_GROUP" \
        --location "$LOCATION" \
        --output table
    
    print_status "Creating storage account: $STATE_STORAGE_ACCOUNT"
    az storage account create \
        --name "$STATE_STORAGE_ACCOUNT" \
        --resource-group "$STATE_RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku "Standard_LRS" \
        --encryption-services blob \
        --output table
    
    print_status "Creating storage container: tfstate"
    az storage container create \
        --name "tfstate" \
        --account-name "$STATE_STORAGE_ACCOUNT" \
        --output table
    
    print_success "Terraform state storage created successfully"
    echo "  Resource Group: $STATE_RESOURCE_GROUP"
    echo "  Storage Account: $STATE_STORAGE_ACCOUNT"
}

# Create service principal
create_service_principal() {
    print_status "Creating service principal for GitHub Actions..."
    
    SP_NAME="github-actions-terraform-$(date +%s)"
    
    # Create service principal with contributor role
    SP_JSON=$(az ad sp create-for-rbac \
        --name "$SP_NAME" \
        --role "Contributor" \
        --scopes "/subscriptions/$SUBSCRIPTION_ID" \
        --json-auth)
    
    # Extract values from JSON
    ARM_CLIENT_ID=$(echo "$SP_JSON" | jq -r '.clientId')
    ARM_CLIENT_SECRET=$(echo "$SP_JSON" | jq -r '.clientSecret')
    ARM_TENANT_ID=$(echo "$SP_JSON" | jq -r '.tenantId')
    ARM_SUBSCRIPTION_ID=$(echo "$SP_JSON" | jq -r '.subscriptionId')
    
    print_success "Service principal created successfully"
    echo "  Name: $SP_NAME"
    echo "  Client ID: $ARM_CLIENT_ID"
}

# Set GitHub secrets
set_github_secrets() {
    if command_exists gh; then
        print_status "Setting GitHub secrets..."
        
        # Check if we're in a git repository
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            print_error "Not in a git repository. Please run this script from your repository root."
            return 1
        fi
        
        # Set secrets
        echo "$ARM_CLIENT_ID" | gh secret set ARM_CLIENT_ID
        echo "$ARM_CLIENT_SECRET" | gh secret set ARM_CLIENT_SECRET
        echo "$ARM_SUBSCRIPTION_ID" | gh secret set ARM_SUBSCRIPTION_ID
        echo "$ARM_TENANT_ID" | gh secret set ARM_TENANT_ID
        echo "$STATE_STORAGE_ACCOUNT" | gh secret set TF_STATE_STORAGE_ACCOUNT
        echo "$STATE_RESOURCE_GROUP" | gh secret set TF_STATE_RESOURCE_GROUP
        
        print_success "GitHub secrets set successfully"
    else
        print_warning "GitHub CLI not available. Please set these secrets manually:"
        echo ""
        echo "Repository Settings > Secrets and variables > Actions"
        echo ""
        echo "Required secrets:"
        echo "  ARM_CLIENT_ID: $ARM_CLIENT_ID"
        echo "  ARM_CLIENT_SECRET: $ARM_CLIENT_SECRET"
        echo "  ARM_SUBSCRIPTION_ID: $ARM_SUBSCRIPTION_ID"
        echo "  ARM_TENANT_ID: $ARM_TENANT_ID"
        echo "  TF_STATE_STORAGE_ACCOUNT: $STATE_STORAGE_ACCOUNT"
        echo "  TF_STATE_RESOURCE_GROUP: $STATE_RESOURCE_GROUP"
        echo ""
    fi
}

# Create environment files
create_environment_files() {
    print_status "Creating environment configuration files..."
    
    # Create environments directory structure
    mkdir -p environments/{dev,staging,prod}
    
    # Create sample .tfvars files if they don't exist
    for env in dev staging prod; do
        for layer in networking security database compute storage monitoring; do
            ENV_FILE="environments/$env/$layer.tfvars"
            if [[ ! -f "$ENV_FILE" ]]; then
                cat > "$ENV_FILE" << EOF
# $env Environment - $layer Layer Configuration
# This file contains $layer-related variables for the $env environment

# =============================================================================
# Environment Configuration
# =============================================================================
environment = "$env"
location    = "East US 2"

# State storage configuration (will be set by pipeline)
state_storage_account_name = ""
state_resource_group_name  = ""

# =============================================================================
# Layer-specific Configuration
# =============================================================================
# Add your $layer-specific variables here

# =============================================================================
# Resource Tagging
# =============================================================================
tags = {
  Environment = "$env"
  Owner      = "platform-team"
  CostCenter = "engineering"
  Project    = "terraform-azure-enterprise"
  Workload   = "$layer"
  CreatedBy  = "terraform"
}
EOF
                print_success "Created $ENV_FILE"
            fi
        done
    done
}

# Update variable files with state storage info
update_variable_files() {
    print_status "Updating variable files with state storage information..."
    
    # Update all .tfvars files to include state storage info
    find environments -name "*.tfvars" -type f | while read -r file; do
        # Update state storage account name
        sed -i.bak "s/state_storage_account_name = \"\"/state_storage_account_name = \"$STATE_STORAGE_ACCOUNT\"/" "$file"
        # Update state resource group name
        sed -i.bak "s/state_resource_group_name = \"\"/state_resource_group_name = \"$STATE_RESOURCE_GROUP\"/" "$file"
        # Remove backup files
        rm -f "$file.bak"
    done
    
    print_success "Variable files updated with state storage information"
}

# Create GitHub environment protection
setup_github_environments() {
    if command_exists gh; then
        print_status "Setting up GitHub environment protection..."
        
        # Note: GitHub environment protection setup via CLI is limited
        # This provides instructions for manual setup
        cat << EOF

=============================================================================
GITHUB ENVIRONMENT PROTECTION SETUP
=============================================================================

Please complete the following steps in your GitHub repository:

1. Go to Settings > Environments
2. Create environment named 'prod'
3. Configure protection rules:
   - Required reviewers: Add platform team members
   - Wait timer: 5 minutes
   - Deployment branches: Restrict to 'main' branch only

4. Create environment named 'staging' (optional protection)
5. Create environment named 'dev' (no protection needed)

6. Set up branch protection for 'main':
   - Required status checks
   - Require pull request reviews (2 reviewers)
   - Dismiss stale reviews
   - Require code owner reviews

EOF
    fi
}

# Validate setup
validate_setup() {
    print_status "Validating setup..."
    
    # Check if resource group exists
    if az group show --name "$STATE_RESOURCE_GROUP" >/dev/null 2>&1; then
        print_success "Resource group '$STATE_RESOURCE_GROUP' exists"
    else
        print_error "Resource group '$STATE_RESOURCE_GROUP' not found"
    fi
    
    # Check if storage account exists
    if az storage account show --name "$STATE_STORAGE_ACCOUNT" --resource-group "$STATE_RESOURCE_GROUP" >/dev/null 2>&1; then
        print_success "Storage account '$STATE_STORAGE_ACCOUNT' exists"
    else
        print_error "Storage account '$STATE_STORAGE_ACCOUNT' not found"
    fi
    
    # Check if container exists
    if az storage container show --name "tfstate" --account-name "$STATE_STORAGE_ACCOUNT" >/dev/null 2>&1; then
        print_success "Storage container 'tfstate' exists"
    else
        print_error "Storage container 'tfstate' not found"
    fi
    
    print_success "Setup validation completed"
}

# Main execution
main() {
    echo "================================================"
    echo "Terraform Azure Enterprise Pipeline Setup"
    echo "================================================"
    echo ""
    
    check_prerequisites
    azure_login
    create_terraform_state_storage
    create_service_principal
    set_github_secrets
    create_environment_files
    update_variable_files
    setup_github_environments
    validate_setup
    
    echo ""
    echo "================================================"
    print_success "Setup completed successfully!"
    echo "================================================"
    echo ""
    echo "Next steps:"
    echo "1. Review and customize environment .tfvars files"
    echo "2. Set up GitHub environment protection (see instructions above)"
    echo "3. Configure branch protection rules"
    echo "4. Test the pipeline with a small change"
    echo ""
    echo "Resources created:"
    echo "  Resource Group: $STATE_RESOURCE_GROUP"
    echo "  Storage Account: $STATE_STORAGE_ACCOUNT"
    echo "  Service Principal: $SP_NAME"
    echo ""
    echo "For support, please contact the Platform Team."
}

# Run main function
main "$@"