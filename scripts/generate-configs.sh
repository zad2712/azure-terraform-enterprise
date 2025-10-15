#!/bin/bash
#
# Generate Environment Configuration Files
# 
# This script creates backend.conf and terraform.tfvars templates
# for all layers and environments

set -e

LAYERS=("compute" "database" "storage" "security" "dns" "monitoring")
ENVIRONMENTS=("dev" "qa" "uat" "prod")
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Generating configuration files for all layers...${NC}\n"

for layer in "${LAYERS[@]}"; do
  for env in "${ENVIRONMENTS[@]}"; do
    ENV_DIR="${BASE_DIR}/layers/${layer}/environments/${env}"
    
    # Create backend.conf
    cat > "${ENV_DIR}/backend.conf" <<EOF
# Backend Configuration for ${env^} Environment
# Layer: ${layer}

storage_account_name = "<STORAGE_ACCOUNT_NAME>"
container_name       = "tfstate"
key                  = "${layer}-${env}.tfstate"
resource_group_name  = "rg-terraform-state"
EOF

    echo -e "${GREEN}✓${NC} Created ${layer}/${env}/backend.conf"
  done
done

echo -e "\n${BLUE}Configuration file generation complete!${NC}"
echo -e "${BLUE}Remember to update <STORAGE_ACCOUNT_NAME> with your actual storage account.${NC}"
