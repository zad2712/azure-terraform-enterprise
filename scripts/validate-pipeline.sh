#!/bin/bash

# GitHub Actions Workflow Validation Script
# This script validates the GitHub Actions workflows and repository structure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Validation counters
ERRORS=0
WARNINGS=0

# Function to increment error count
error() {
    print_error "$1"
    ((ERRORS++))
}

# Function to increment warning count
warning() {
    print_warning "$1"
    ((WARNINGS++))
}

# Validate directory structure
validate_directory_structure() {
    print_status "Validating directory structure..."
    
    # Required directories
    required_dirs=(
        ".github/workflows"
        "environments/dev"
        "environments/staging"
        "environments/prod"
        "layers/networking"
        "layers/security"
        "layers/database"
        "layers/compute"
        "layers/storage"
        "layers/monitoring"
        "modules"
        "scripts"
        "docs"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_success "Directory exists: $dir"
        else
            error "Missing required directory: $dir"
        fi
    done
}

# Validate workflow files
validate_workflows() {
    print_status "Validating GitHub Actions workflow files..."
    
    # Required workflow files
    required_workflows=(
        ".github/workflows/terraform-plan.yml"
        ".github/workflows/terraform-apply.yml"
        ".github/workflows/terraform-destroy.yml"
        ".github/workflows/reusable-terraform-layer.yml"
    )
    
    for workflow in "${required_workflows[@]}"; do
        if [[ -f "$workflow" ]]; then
            print_success "Workflow file exists: $workflow"
            
            # Basic YAML syntax validation
            if command -v yamllint >/dev/null 2>&1; then
                if yamllint "$workflow" >/dev/null 2>&1; then
                    print_success "YAML syntax valid: $workflow"
                else
                    warning "YAML syntax issues in: $workflow"
                fi
            else
                warning "yamllint not installed - skipping YAML validation"
            fi
        else
            error "Missing required workflow file: $workflow"
        fi
    done
}

# Validate environment files
validate_environment_files() {
    print_status "Validating environment configuration files..."
    
    environments=("dev" "staging" "prod")
    layers=("networking" "security" "database" "compute" "storage" "monitoring")
    
    for env in "${environments[@]}"; do
        for layer in "${layers[@]}"; do
            tfvars_file="environments/$env/$layer.tfvars"
            
            if [[ -f "$tfvars_file" ]]; then
                print_success "Environment file exists: $tfvars_file"
                
                # Check for required variables
                if grep -q "environment.*=.*\"$env\"" "$tfvars_file"; then
                    print_success "Environment variable set correctly in: $tfvars_file"
                else
                    warning "Environment variable not set correctly in: $tfvars_file"
                fi
                
                # Check for location variable
                if grep -q "location.*=" "$tfvars_file"; then
                    print_success "Location variable found in: $tfvars_file"
                else
                    warning "Location variable missing in: $tfvars_file"
                fi
                
                # Check for tags
                if grep -q "tags.*=" "$tfvars_file"; then
                    print_success "Tags variable found in: $tfvars_file"
                else
                    warning "Tags variable missing in: $tfvars_file"
                fi
            else
                warning "Missing environment file: $tfvars_file"
            fi
        done
    done
}

# Validate layer structure
validate_layer_structure() {
    print_status "Validating Terraform layer structure..."
    
    layers=("networking" "security" "database" "compute" "storage" "monitoring")
    
    for layer in "${layers[@]}"; do
        layer_dir="layers/$layer"
        
        if [[ -d "$layer_dir" ]]; then
            # Check for main Terraform files
            required_files=("main.tf" "variables.tf" "outputs.tf")
            
            for file in "${required_files[@]}"; do
                if [[ -f "$layer_dir/$file" ]]; then
                    print_success "Layer file exists: $layer_dir/$file"
                else
                    warning "Missing layer file: $layer_dir/$file"
                fi
            done
            
            # Check for provider configuration
            if grep -q "terraform\s*{" "$layer_dir/main.tf" 2>/dev/null; then
                print_success "Terraform block found in: $layer_dir/main.tf"
            else
                warning "Terraform block missing in: $layer_dir/main.tf"
            fi
            
            # Check for backend configuration
            if grep -q "backend.*\"azurerm\"" "$layer_dir/main.tf" 2>/dev/null; then
                print_success "Azure backend configured in: $layer_dir/main.tf"
            else
                warning "Azure backend not configured in: $layer_dir/main.tf"
            fi
        else
            error "Missing layer directory: $layer_dir"
        fi
    done
}

# Validate documentation
validate_documentation() {
    print_status "Validating documentation..."
    
    required_docs=(
        "README.md"
        "PIPELINE_README.md"
        "docs/github-actions-pipeline-guide.md"
    )
    
    for doc in "${required_docs[@]}"; do
        if [[ -f "$doc" ]]; then
            print_success "Documentation exists: $doc"
            
            # Check file size (should not be empty)
            if [[ -s "$doc" ]]; then
                print_success "Documentation has content: $doc"
            else
                warning "Documentation file is empty: $doc"
            fi
        else
            warning "Missing documentation: $doc"
        fi
    done
}

# Validate scripts
validate_scripts() {
    print_status "Validating scripts..."
    
    required_scripts=(
        "scripts/setup-pipeline.sh"
    )
    
    for script in "${required_scripts[@]}"; do
        if [[ -f "$script" ]]; then
            print_success "Script exists: $script"
            
            # Check if script is executable
            if [[ -x "$script" ]]; then
                print_success "Script is executable: $script"
            else
                warning "Script is not executable: $script (run: chmod +x $script)"
            fi
            
            # Basic shell script validation
            if bash -n "$script" 2>/dev/null; then
                print_success "Script syntax valid: $script"
            else
                error "Script syntax error in: $script"
            fi
        else
            error "Missing required script: $script"
        fi
    done
}

# Check GitHub repository settings (if GitHub CLI is available)
validate_github_settings() {
    if command -v gh >/dev/null 2>&1; then
        print_status "Validating GitHub repository settings..."
        
        # Check if we're in a git repository
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
            warning "Not in a git repository - skipping GitHub validation"
            return
        fi
        
        # Check for required secrets (this will fail if not set, which is expected)
        required_secrets=(
            "ARM_CLIENT_ID"
            "ARM_CLIENT_SECRET"
            "ARM_SUBSCRIPTION_ID"
            "ARM_TENANT_ID"
            "TF_STATE_STORAGE_ACCOUNT"
            "TF_STATE_RESOURCE_GROUP"
        )
        
        print_status "Checking for required GitHub secrets..."
        for secret in "${required_secrets[@]}"; do
            if gh secret list | grep -q "$secret"; then
                print_success "Secret configured: $secret"
            else
                warning "Secret not configured: $secret"
            fi
        done
        
        # Check branch protection (if we have permissions)
        if gh api repos/:owner/:repo/branches/main/protection >/dev/null 2>&1; then
            print_success "Branch protection enabled on main"
        else
            warning "Branch protection not configured on main branch"
        fi
        
    else
        warning "GitHub CLI not available - skipping GitHub repository validation"
    fi
}

# Validate Terraform syntax (if Terraform is available)
validate_terraform_syntax() {
    if command -v terraform >/dev/null 2>&1; then
        print_status "Validating Terraform syntax..."
        
        layers=("networking" "security" "database" "compute" "storage" "monitoring")
        
        for layer in "${layers[@]}"; do
            layer_dir="layers/$layer"
            
            if [[ -d "$layer_dir" ]]; then
                print_status "Validating Terraform syntax in: $layer_dir"
                
                # Change to layer directory and validate
                (
                    cd "$layer_dir"
                    if terraform fmt -check >/dev/null 2>&1; then
                        print_success "Terraform formatting correct in: $layer_dir"
                    else
                        warning "Terraform formatting issues in: $layer_dir (run: terraform fmt)"
                    fi
                    
                    # Note: We skip terraform validate as it requires initialization
                    # which needs Azure credentials
                )
            fi
        done
    else
        warning "Terraform not available - skipping Terraform syntax validation"
    fi
}

# Generate validation report
generate_report() {
    echo ""
    echo "================================================"
    echo "VALIDATION REPORT SUMMARY"
    echo "================================================"
    
    if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
        print_success "All validations passed! Repository is ready for use."
    elif [[ $ERRORS -eq 0 ]]; then
        print_warning "Validation completed with $WARNINGS warnings"
        echo "The repository is functional but some improvements are recommended."
    else
        print_error "Validation failed with $ERRORS errors and $WARNINGS warnings"
        echo "Please fix the errors before using the pipeline."
    fi
    
    echo ""
    echo "Summary:"
    echo "  Errors: $ERRORS"
    echo "  Warnings: $WARNINGS"
    echo ""
    
    if [[ $ERRORS -gt 0 ]]; then
        echo "Next steps:"
        echo "1. Fix all reported errors"
        echo "2. Re-run this validation script"
        echo "3. Set up GitHub secrets using: ./scripts/setup-pipeline.sh"
        echo "4. Configure GitHub environment protection"
        exit 1
    else
        echo "Next steps:"
        echo "1. Review and address any warnings"
        echo "2. Run setup script: ./scripts/setup-pipeline.sh"
        echo "3. Configure GitHub environment protection"
        echo "4. Test the pipeline with a small change"
    fi
}

# Main execution
main() {
    echo "================================================"
    echo "GitHub Actions Pipeline Validation"
    echo "================================================"
    echo ""
    
    validate_directory_structure
    validate_workflows
    validate_environment_files
    validate_layer_structure
    validate_documentation
    validate_scripts
    validate_github_settings
    validate_terraform_syntax
    generate_report
}

# Check if script is being run from repository root
if [[ ! -d ".github/workflows" ]]; then
    print_error "Please run this script from the repository root directory"
    exit 1
fi

# Run main function
main "$@"