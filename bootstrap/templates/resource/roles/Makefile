#############################################################################
# auto-generated from bootstrap
#
# BOOTSTRAP VERSION: 0.0.3
#
# deploys AWS Roles for single cluster
#
# REQUIRED:
# ENV= the name of the cluster environment (dev, qa, staging, production)
# CLUSTER_NAME= valid eks cluster name
#############################################################################

CURRENT_DIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
RESOURCES_DIR = $(CURRENT_DIR)
TF_VARS_COMMON = ../../env/${ENV}/terraform.tfvars
TF_VARS_RESOURCE = ../../env/${ENV}/roles.tfvars
TF_BACKEND = ../../env/${ENV}/terraform.backend
TF_PLAN = terraform.tfplan
BACKEND_KEY = ${CLUSTER_NAME}.role.tfstate
EXEC_DIR = $(shell pwd)

.PHONY: cleanup

cleanup:
	-rm -rf .terraform; rm terraform.tfplan; rm terraform.tfstate

init-upgrade:
	terraform init -upgrade -backend-config=$(TF_BACKEND) -var-file=$(TF_VARS_COMMON) -backend-config="key=${BACKEND_KEY}"

init:
	terraform init -upgrade -backend-config=$(TF_BACKEND) -var-file=$(TF_VARS_COMMON) -backend-config="key=${BACKEND_KEY}"

plan: cleanup init
	../kubeconfig ${CLUSTER_NAME}
	terraform plan -var-file=$(TF_VARS_COMMON) -var-file=$(TF_VARS_RESOURCE) -var cluster_name=${CLUSTER_NAME} -out=$(TF_PLAN) -compact-warnings

apply: plan
	terraform apply $(TF_PLAN)

tflint: init
	terraform fmt -recursive -diff -check
	tflint --ignore-module tools .

destroy-prompt: cleanup init
	terraform destroy -var-file=$(TF_VARS_COMMON) -var-file=$(TF_VARS_RESOURCE) -var cluster_name=${CLUSTER_NAME}

destroy: cleanup init
	terraform destroy -var-file=$(TF_VARS_COMMON) -var-file=$(TF_VARS_RESOURCE) -var cluster_name=${CLUSTER_NAME} -auto-approve

providers-lock:
	terraform providers lock -platform=linux_arm64 -platform=linux_amd64 -platform=darwin_amd64 -platform=windows_amd64
