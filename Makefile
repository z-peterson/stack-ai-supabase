.PHONY: init validate lint test helm-lint helm-template kubeconform shellcheck clean

TERRAFORM_DIR := terraform
KUBERNETES_DIR := kubernetes
SCRIPTS_DIR := scripts

# Initialize terraform and download providers
init:
	cd $(TERRAFORM_DIR) && terraform init -backend=false

# Terraform validate
validate:
	cd $(TERRAFORM_DIR) && terraform validate

# TFLint
lint:
	cd $(TERRAFORM_DIR) && tflint --recursive

# Helm lint
helm-lint:
	helm lint -f $(KUBERNETES_DIR)/values/supabase-production.yaml supabase-community/supabase

# Helm template render
helm-template:
	helm template supabase supabase-community/supabase \
		-f $(KUBERNETES_DIR)/values/supabase-production.yaml \
		--namespace supabase > /dev/null

# Validate K8s manifests against schemas
kubeconform:
	find $(KUBERNETES_DIR)/manifests -name '*.yaml' | xargs kubeconform -strict -ignore-missing-schemas

# Shellcheck all scripts
shellcheck:
	shellcheck $(SCRIPTS_DIR)/*.sh

# Run all tests
test: validate lint helm-lint helm-template kubeconform shellcheck
	@echo "All tests passed."

# Clean generated files
clean:
	rm -rf $(TERRAFORM_DIR)/.terraform
	rm -f $(TERRAFORM_DIR)/.terraform.lock.hcl
