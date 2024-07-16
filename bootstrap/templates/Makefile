#############################################################################
# auto-generated from bootstrap
#
# BOOTSTRAP VERSION: 0.0.1
#
# TOOL FOR DEPLOYING AWS RESOURCES TO ANY ENVIRONMENT OR ACCOUNT
# USER MUST PASS IN THE FOLLOWING VARS TO THIS MAKE. THEY CAN ALSO
# BE SET AS ENV VARS FROM A PIPELINE ETC...
# REQUIRED:
# RESOURCE= specifies the module to deploy (s3, rds, secrets, redis, other...)
# ENV= the name of the environment (dev, qa, staging, production, etc...)
# REGION= valid aws region name where the resources are to be created
#
# NOTE: orchestrating the deployment of multiple resources to one or more 
#       regions should be handled in the pipeline. Make multiple calls to
#       this Makefile as needed. 
#############################################################################

CURRENT_DIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
RESOURCES_DIR = $(CURRENT_DIR)/resource
TF_VARS_COMMON = ../../env/${ENV}/terraform.tfvars
TF_BACKEND = ../../env/${ENV}/terraform.backend
TF_PLAN = terraform.tfplan
TF_VARS_RESOURCE = ../../env/${ENV}/${RESOURCE}.tfvars
PRODUCT=$(word 2,$(subst =, ,$(shell grep "^product =.\+$$" $(TF_VARS_COMMON) | sed 's/ //g' | tr -d '"')))

RESOURCE_UPPER = $(shell echo '${RESOURCE}' | tr '[:lower:]' '[:upper:]')
BACKEND_KEY = ${RESOURCE}.tfstate

.PHONY: cleanup

cleanup:
	-cd $(RESOURCES_DIR)/${RESOURCE}; rm -rf .terraform; rm terraform.tfplan; rm terraform.tfstate

init-upgrade:
	cd $(RESOURCES_DIR)/${RESOURCE}; terraform init -upgrade -backend-config=$(TF_BACKEND) -var-file=$(TF_VARS_COMMON) -backend-config="key=${BACKEND_KEY}"

init:
	cd $(RESOURCES_DIR)/${RESOURCE}; terraform init -upgrade -backend-config=$(TF_BACKEND) -var-file=$(TF_VARS_COMMON) -backend-config="key=${BACKEND_KEY}"

plan: cleanup init
	cd $(RESOURCES_DIR)/${RESOURCE}; terraform plan -var-file=$(TF_VARS_COMMON) -var-file=$(TF_VARS_RESOURCE) -var environment=${ENV} -out=$(TF_PLAN) -compact-warnings

plan-debug: cleanup init
	cd $(RESOURCES_DIR)/${RESOURCE}; export TF_LOG=TRACE; terraform plan -var-file=$(TF_VARS_COMMON) -var-file=$(TF_VARS_RESOURCE) -var environment=${ENV} -out=$(TF_PLAN)

plan-destroy: cleanup init
	cd $(RESOURCES_DIR)/${RESOURCE}; terraform plan -destroy -var-file=$(TF_VARS_COMMON) -var-file=$(TF_VARS_RESOURCE) -var environment=${ENV} -out=$(TF_PLAN)

apply: plan
	cd $(RESOURCES_DIR)/${RESOURCE}; terraform apply $(TF_PLAN)

tflint: init
	cd $(RESOURCES_DIR)/${RESOURCE}; terraform fmt -recursive -diff -check
	tflint --ignore-module tools ${RESOURCE}

destroy-prompt: cleanup init
	cd $(RESOURCES_DIR)/${RESOURCE}; terraform destroy -var-file=$(TF_VARS_COMMON) -var-file=$(TF_VARS_RESOURCE) -var environment=${ENV}

destroy: cleanup init
	cd $(RESOURCES_DIR)/${RESOURCE}; terraform destroy -var-file=$(TF_VARS_COMMON) -var-file=$(TF_VARS_RESOURCE) -var environment=${ENV} -auto-approve

providers-lock:
	cd $(RESOURCES_DIR)/$(RESOURCE); terraform providers lock -platform=linux_arm64 -platform=linux_amd64 -platform=darwin_amd64 -platform=windows_amd64

eks-lb-controller-verify: plan
	@cd $(RESOURCES_DIR)/${RESOURCE} && for c in $$(terraform output cluster_names_string | sed -e 's/^"//' -e 's/"$$//') ; do make -C ../eks-load-balancer-controller CLUSTER_NAME=$$c verify ; done

eks-lb-controller-deploy: plan
	@cd $(RESOURCES_DIR)/${RESOURCE} && for c in $$(terraform output cluster_names_string | sed -e 's/^"//' -e 's/"$$//') ; do make -C ../eks-load-balancer-controller CLUSTER_NAME=$$c apply ; done

eks-lb-controller-remove: plan
	@cd $(RESOURCES_DIR)/${RESOURCE} && for c in $$(terraform output cluster_names_string | sed -e 's/^"//' -e 's/"$$//') ; do make -C ../eks-load-balancer-controller CLUSTER_NAME=$$c destroy ; done

eks-ext-addons-deploy: plan
	@cd $(RESOURCES_DIR)/${RESOURCE} && for c in $$(terraform output cluster_names_string | sed -e 's/^"//' -e 's/"$$//') ; do add-ons/installer install $$c ; done

eks-ext-addons-remove: plan
	@cd $(RESOURCES_DIR)/${RESOURCE} && for c in $$(terraform output cluster_names_string | sed -e 's/^"//' -e 's/"$$//') ; do add-ons/installer remove $$c ; done

# no need to use sed to strip quotes with this method
eks-ext-addons-verify: plan
	@cd $(RESOURCES_DIR)/${RESOURCE} && for c in $$(terraform output -json | jq -r .cluster_names_string.value) ; do add-ons/verify $$c ; done

# ------- EKS UPDATE CONFIGMAP ---------
eks-update-configmap: plan
	@cd $(RESOURCES_DIR)/${RESOURCE} && for c in $$(terraform output cluster_names_string | sed -e 's/^"//' -e 's/"$$//') ; do ./update_configmap $$c ; done

# ------- ISTIO OPERATOR DEPLOY -----------
eks-istio-deploy: plan
	@cd $(RESOURCES_DIR)/${RESOURCE} && for c in $$(terraform output cluster_names_string | sed -e 's/^"//' -e 's/"$$//') ; do ../istio/deploy install $$c ; done

eks-istio-remove: plan
	@cd $(RESOURCES_DIR)/${RESOURCE} && for c in $$(terraform output cluster_names_string | sed -e 's/^"//' -e 's/"$$//') ; do ../istio/deploy remove $$c ; done

