#!/bin/bash
#
# Generate Backend Configuration Files
# 
# This script creates backend.conf files for all layers and environments
# Usage: ./generate-backend-configs.sh <storage-account-name>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <storage-account-name>"
    echo "Example: $0 sttfstate12345"
    exit 1
fi

STORAGE_ACCOUNT_NAME="$1"
LAYERS=("networking" "security" "database" "storage" "compute" "dns" "monitoring")
ENVIRONMENTS=("dev" "qa" "uat" "prod")
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Generating Backend Configuration Files             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}Storage Account: ${STORAGE_ACCOUNT_NAME}${NC}\n"

TOTAL_FILES=0

for layer in "${LAYERS[@]}"; do
  echo -e "${BLUE}Layer: ${layer}${NC}"
  
  for env in "${ENVIRONMENTS[@]}"; do
    ENV_DIR="${BASE_DIR}/layers/${layer}/environments/${env}"
    BACKEND_FILE="${ENV_DIR}/backend.conf"
    
    # Create backend.conf
    cat > "${BACKEND_FILE}" <<EOF
# Backend Configuration for ${env^} Environment
# Layer: ${layer}
#
# Initialize Terraform with:
# terraform init -backend-config=environments/${env}/backend.conf

storage_account_name = "${STORAGE_ACCOUNT_NAME}"
container_name       = "tfstate"
key                  = "${layer}-${env}.tfstate"
resource_group_name  = "rg-terraform-state"
EOF

    echo -e "  ${GREEN}✓${NC} ${env}/backend.conf"
    ((TOTAL_FILES++))
  done
  echo ""
done

echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Configuration Generation Complete!                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}\n"
echo -e "${GREEN}Total files created: ${TOTAL_FILES}${NC}"
echo -e "${BLUE}Storage account used: ${STORAGE_ACCOUNT_NAME}${NC}\n"

echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Review the generated backend.conf files"
echo -e "2. Initialize Terraform for each layer:"
echo -e "   ${BLUE}cd layers/networking${NC}"
echo -e "   ${BLUE}terraform init -backend-config=environments/dev/backend.conf${NC}"
echo -e "3. Update terraform.tfvars files with your values"
echo -e "4. Deploy in order: networking → security → database → storage → compute → dns → monitoring\n"
