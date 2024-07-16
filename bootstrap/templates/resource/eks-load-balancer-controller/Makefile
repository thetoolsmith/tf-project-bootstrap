#############################################################################
# auto-generated from bootstrap
#
# BOOTSTRAP VERSION: 0.0.3
#
# deploys eks-load-balancer-controller to single cluster
#
# REQUIRED:
# ENV= the name of the cluster environment (dev, qa, staging, production)
# CLUSTER_NAME= valid eks cluster name
#############################################################################

CURRENT_DIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
RESOURCES_DIR = $(CURRENT_DIR)
# RESOURCE = lb-controller
TF_VARS_COMMON = ../../env/${ENV}/terraform.tfvars
TF_BACKEND = ../../env/${ENV}/terraform.backend
TF_PLAN = terraform.tfplan
BACKEND_KEY = ${CLUSTER_NAME}.lb-controller.tfstate
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
	terraform plan -var-file=$(TF_VARS_COMMON) -var cluster_name=${CLUSTER_NAME} -out=$(TF_PLAN) -compact-warnings

verify: plan
	source ../functions && verify_deployment aws-load-balancer-controller

apply: plan
	terraform apply $(TF_PLAN)
	source ../functions && verify_deployment aws-load-balancer-controller

tflint: init
	terraform fmt -recursive -diff -check
	tflint --ignore-module tools .

destroy-prompt: cleanup init
	terraform destroy -var-file=$(TF_VARS_COMMON) -var cluster_name=${CLUSTER_NAME}
	-helm uninstall aws-load-balancer-controller -n aws-lb-controller
	source ../functions && verify_deployments

destroy: cleanup init
	terraform destroy -var-file=$(TF_VARS_COMMON) -var cluster_name=${CLUSTER_NAME} -auto-approve
	-helm uninstall aws-load-balancer-controller -n aws-lb-controller
	source ../functions && verify_deployments

providers-lock:
	terraform providers lock -platform=linux_arm64 -platform=linux_amd64 -platform=darwin_amd64 -platform=windows_amd64

