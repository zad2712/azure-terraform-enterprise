.PHONY: help init plan apply destroy validate format lint clean

# Variables
LAYER ?= networking
ENV ?= dev

# Colors for output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
BLUE   := $(shell tput -Txterm setaf 4)
RESET  := $(shell tput -Txterm sgr0)

help: ## Show this help message
	@echo '${BLUE}═══════════════════════════════════════════════════════════${RESET}'
	@echo '${BLUE}  Terraform Azure Enterprise - Makefile Commands${RESET}'
	@echo '${BLUE}═══════════════════════════════════════════════════════════${RESET}'
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET} ${YELLOW}LAYER=${GREEN}<layer>${RESET} ${YELLOW}ENV=${GREEN}<env>${RESET}'
	@echo ''
	@echo 'Examples:'
	@echo '  make init LAYER=networking ENV=dev'
	@echo '  make plan LAYER=compute ENV=prod'
	@echo '  make apply LAYER=database ENV=qa'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${GREEN}%-15s${RESET} %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform with backend config
	@echo "${BLUE}Initializing Terraform for $(LAYER)/$(ENV)...${RESET}"
	@cd layers/$(LAYER) && \
		terraform init -backend-config=environments/$(ENV)/backend.conf

plan: ## Run terraform plan
	@echo "${BLUE}Running plan for $(LAYER)/$(ENV)...${RESET}"
	@cd layers/$(LAYER) && \
		terraform plan -var-file=environments/$(ENV)/terraform.tfvars -out=tfplan-$(ENV)

apply: ## Apply terraform changes
	@echo "${YELLOW}Applying changes for $(LAYER)/$(ENV)...${RESET}"
	@cd layers/$(LAYER) && \
		terraform apply tfplan-$(ENV)
	@echo "${GREEN}✓ Apply complete!${RESET}"

apply-auto: ## Apply without confirmation (CI/CD use)
	@echo "${YELLOW}Auto-applying changes for $(LAYER)/$(ENV)...${RESET}"
	@cd layers/$(LAYER) && \
		terraform apply -auto-approve -var-file=environments/$(ENV)/terraform.tfvars
	@echo "${GREEN}✓ Apply complete!${RESET}"

destroy: ## Destroy infrastructure
	@echo "${YELLOW}⚠ WARNING: This will destroy resources in $(LAYER)/$(ENV)${RESET}"
	@echo "${YELLOW}Press Ctrl+C to cancel or Enter to continue...${RESET}"
	@read confirmation
	@cd layers/$(LAYER) && \
		terraform destroy -var-file=environments/$(ENV)/terraform.tfvars

validate: ## Validate terraform configuration
	@echo "${BLUE}Validating $(LAYER)/$(ENV)...${RESET}"
	@cd layers/$(LAYER) && \
		terraform validate

format: ## Format terraform files
	@echo "${BLUE}Formatting Terraform files...${RESET}"
	@terraform fmt -recursive
	@echo "${GREEN}✓ Format complete!${RESET}"

lint: ## Run tflint on configuration
	@echo "${BLUE}Running tflint on $(LAYER)...${RESET}"
	@cd layers/$(LAYER) && \
		tflint --init && tflint

clean: ## Clean terraform files
	@echo "${BLUE}Cleaning Terraform artifacts for $(LAYER)/$(ENV)...${RESET}"
	@cd layers/$(LAYER) && \
		rm -rf .terraform/ tfplan-* .terraform.lock.hcl
	@echo "${GREEN}✓ Clean complete!${RESET}"

output: ## Show terraform outputs
	@cd layers/$(LAYER) && \
		terraform output

output-json: ## Show terraform outputs as JSON
	@cd layers/$(LAYER) && \
		terraform output -json

refresh: ## Refresh terraform state
	@echo "${BLUE}Refreshing state for $(LAYER)/$(ENV)...${RESET}"
	@cd layers/$(LAYER) && \
		terraform refresh -var-file=environments/$(ENV)/terraform.tfvars

show: ## Show terraform state
	@cd layers/$(LAYER) && \
		terraform show

state-list: ## List resources in state
	@cd layers/$(LAYER) && \
		terraform state list

state-pull: ## Pull current state to stdout
	@cd layers/$(LAYER) && \
		terraform state pull

graph: ## Generate dependency graph
	@cd layers/$(LAYER) && \
		terraform graph | dot -Tsvg > graph-$(ENV).svg
	@echo "${GREEN}✓ Graph saved to layers/$(LAYER)/graph-$(ENV).svg${RESET}"

validate-all: ## Validate all layers and environments
	@echo "${BLUE}Validating all configurations...${RESET}"
	@for layer in networking security database storage compute dns monitoring; do \
		echo "${YELLOW}Validating $$layer...${RESET}"; \
		cd layers/$$layer && terraform validate && cd ../..; \
	done
	@echo "${GREEN}✓ All validations complete!${RESET}"

format-all: ## Format all terraform files
	@echo "${BLUE}Formatting all Terraform files...${RESET}"
	@terraform fmt -recursive
	@echo "${GREEN}✓ All files formatted!${RESET}"

# Deployment targets for all layers in order
deploy-dev: ## Deploy all layers to dev
	@$(MAKE) deploy-env ENV=dev

deploy-qa: ## Deploy all layers to qa
	@$(MAKE) deploy-env ENV=qa

deploy-uat: ## Deploy all layers to uat
	@$(MAKE) deploy-env ENV=uat

deploy-prod: ## Deploy all layers to prod
	@$(MAKE) deploy-env ENV=prod

deploy-env:
	@echo "${BLUE}═══════════════════════════════════════════════════════════${RESET}"
	@echo "${BLUE}  Deploying all layers to $(ENV)...${RESET}"
	@echo "${BLUE}═══════════════════════════════════════════════════════════${RESET}"
	@for layer in networking security database storage compute dns monitoring; do \
		echo ""; \
		echo "${YELLOW}▶ Deploying $$layer to $(ENV)...${RESET}"; \
		$(MAKE) init LAYER=$$layer ENV=$(ENV); \
		$(MAKE) plan LAYER=$$layer ENV=$(ENV); \
		$(MAKE) apply LAYER=$$layer ENV=$(ENV); \
		echo "${GREEN}✓ $$layer deployed successfully${RESET}"; \
	done
	@echo ""
	@echo "${GREEN}═══════════════════════════════════════════════════════════${RESET}"
	@echo "${GREEN}  ✓ All layers deployed to $(ENV)!${RESET}"
	@echo "${GREEN}═══════════════════════════════════════════════════════════${RESET}"

# Emergency operations
force-unlock: ## Force unlock state (requires LOCK_ID)
	@echo "${YELLOW}Force unlocking state for $(LAYER)...${RESET}"
	@cd layers/$(LAYER) && \
		terraform force-unlock $(LOCK_ID)

state-backup: ## Backup current state
	@echo "${BLUE}Backing up state for $(LAYER)/$(ENV)...${RESET}"
	@cd layers/$(LAYER) && \
		terraform state pull > state-backup-$(ENV)-$(shell date +%Y%m%d-%H%M%S).json
	@echo "${GREEN}✓ State backed up!${RESET}"

# Documentation
docs: ## Generate module documentation
	@echo "${BLUE}Generating module documentation...${RESET}"
	@terraform-docs markdown table --output-file README.md --output-mode inject modules/

# Security and Compliance
security-scan: ## Run security scan (requires tfsec)
	@echo "${BLUE}Running security scan for $(LAYER)...${RESET}"
	@cd layers/$(LAYER) && \
		tfsec .

compliance-check: ## Check compliance (requires checkov)
	@echo "${BLUE}Running compliance check for $(LAYER)...${RESET}"
	@cd layers/$(LAYER) && \
		checkov -d .

cost-estimate: ## Estimate costs (requires Infracost)
	@echo "${BLUE}Estimating costs for $(LAYER)/$(ENV)...${RESET}"
	@cd layers/$(LAYER) && \
		infracost breakdown --path . --terraform-var-file environments/$(ENV)/terraform.tfvars
