###########################################################################################################
# GENERIC TOOL FOR BOOTSTRAPPING NEW AWS ENVIRONMENTS MANAGED BY TERRAFORM
# USER MUST PASS IN THE FOLLOWING VARS TO THIS MAKE
# REQUIRED:
# PRODUCT= specifies the product name, service name or suite name
# OWNER= specifies the team/owner of the product
# PRODUCTPATH= specifies the local path to the repo where the boostrap files will be created and committed
# ENV= the name to be of the environment being boostrapped (use any names such as dev, qa, staging, production)
# REGION= valid aws region name where the state backend and other bootstrap resources are to be created. This
#         is not the region where you wish to deploy resources to. This "base" region is for the bootstrapped
#         project backend and other project common resources (not the resoures you will deploy for the project)
# SRE= initial SRE group to manage the bootstraped ENV
#
# OPTIONAL: <command line or environment vars>
# SEED_RESOURCE=true|false will optionally create default tfvars for supported resources
# MCRYPT_KEY= specifies the mcrypt key for encrypt/decrypt bootstrap state file.
#
# TIP:
# Only bootstrap state will be encrypted and stored as a file. The s3 (or azure storage) backend for each 
# project that is bootstrapped will reside in whatever REGION is specified in the bootstrap command.
# That backend will be where the state lives for all the resources you deploy after the project and
# environments are bootstrapped.
#
# TIP: You will run bootstrap once for each product/environment combination. For example.....
#      If you want to create infrastructure for product COOLSERVICE for a separate dev, staging and production
#      environments, you would run the bootstrap command 3 times
#      PRODUCT=COOLSERVICE ENV=dev ... remainder of command parameters...
#      PRODUCT=COOLSERVICE ENV=staging ... remainder of command parameters...
#      PRODUCT=COOLSERVICE ENV=production ... remainder of command parameters...
###########################################################################################################

BOOTSTRAP_VERSION = $(shell git rev-parse --abbrev-ref HEAD)
CURRENT_DIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
TF_INFRA_DIR = ${PRODUCTPATH}/terraform
TF_ENV_CONFIG_DIR = $(TF_INFRA_DIR)/env/${ENV}
TF_RESOURCE_DIR = $(TF_INFRA_DIR)/resource
TF_ENV_VARS_COMMON = $(TF_INFRA_DIR)/env/${ENV}/terraform.tfvars
TF_PLAN = terraform.tfplan
TF_ENV_BACKEND = $(TF_INFRA_DIR)/env/${ENV}/terraform.backend
STATEPATH = $(TF_INFRA_DIR)/state
ENVFILEPATH = env 
ENVDIRPATH = env/${ENV}
STATEFILEPATH = state

SED_CMD = sed -i
MCRYPT_CMD = mcrypt
UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
  SED_CMD = sed -i '' -E
  MCRYPT_CMD = mcrypt --no-openpgp
endif

YEAR := $(shell date +'%Y')
EXPIRE = 2
EXPIRE_YEAR = $$(( $(YEAR) + $(EXPIRE) ))
END_YEAR = $(EXPIRE_YEAR)

check-region:
ifndef REGION
	$(error REGION is undefined)
endif

check-product:
ifndef PRODUCT
	$(error PRODUCT is undefined)
endif

check-owner:
ifndef OWNER
	$(error OWNER is undefined)
endif

check-env:
ifndef ENV
	$(error ENV is undefined)
endif

check-outpath:
ifndef PRODUCTPATH
	$(error PRODUCTPATH is undefined)
endif

check-sre:
ifndef SRE
	$(error SRE is undefined)
endif

check-mcrypt-key:
ifndef MCRYPT_KEY
 $(error MCRYPT_KEY is undefined)
endif

check-mcrypt: check-mcrypt-key
ifeq ($(shell which mcrypt),)
  $(error mcrypt not found)
endif

check-bootstrap: check-mcrypt
ifeq ("${BOOTSTRAP_VERSION}", "main")
	$(error cannot bootstrap from main branch)
endif

version-bump: check-bootstrap
	@find templates/resource -type f -name '*.tf' | xargs $(SED_CMD) 's/BOOTSTRAP VERSION: [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/BOOTSTRAP VERSION: $(BOOTSTRAP_VERSION)/g'
	@find templates/resource -type f -name '*.tfvars' | xargs $(SED_CMD) 's/BOOTSTRAP VERSION: [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/BOOTSTRAP VERSION: $(BOOTSTRAP_VERSION)/g'
	@find templates/resource -type f -name '*.sh' | xargs $(SED_CMD) 's/BOOTSTRAP VERSION: [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/BOOTSTRAP VERSION: $(BOOTSTRAP_VERSION)/g'
	@find templates/resource -type f -name '*.yaml' | xargs $(SED_CMD) 's/BOOTSTRAP VERSION: [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/BOOTSTRAP VERSION: $(BOOTSTRAP_VERSION)/g'
	@find templates -type f -name 'Makefile' | xargs $(SED_CMD) 's/BOOTSTRAP VERSION: [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/BOOTSTRAP VERSION: $(BOOTSTRAP_VERSION)/g'
	@find templates/resource -type f -name 'functions' -o -name 'kubeconfig' | xargs $(SED_CMD) 's/BOOTSTRAP VERSION: [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/BOOTSTRAP VERSION: $(BOOTSTRAP_VERSION)/g'
	@find templates/state -type f -name '*.template' | xargs $(SED_CMD) 's/BOOTSTRAP VERSION: [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/BOOTSTRAP VERSION: $(BOOTSTRAP_VERSION)/g'
	@$(SED_CMD) 's/BOOTSTRAP VERSION: [[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/BOOTSTRAP VERSION: $(BOOTSTRAP_VERSION)/g' templates/Makefile

# seed-common is not used currently. It's for future if we want to update the common tfvars and backend tf
seed-common:
ifeq (${SEED_RESOURCE}, true)
	@set -e; \
	echo '############################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# ${ENV} COMMON TF VARIABLES\n#\n# DO NOT EDIT THIS FILE\n# USE RESOURCE SPECIFIC VARS\n############################\n' >$(TF_ENV_VARS_COMMON)
	cat templates/state/common.vars.template >>$(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__ENVIRONMENT__/${ENV}/g' $(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__REGION__/${REGION}/g' $(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__PRODUCT__/${PRODUCT}/g' $(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__OWNER__/${OWNER}/g' $(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__INITIAL_SRE__/${SRE}/g' $(TF_ENV_VARS_COMMON)
endif

seed-resources:
ifeq (${SEED_RESOURCE}, true)
	@set -e; \
	mkdir -p $(TF_INFRA_DIR)/resource;\
	rsync -a templates/resource/* $(TF_INFRA_DIR)/resource/ --exclude s3 --exclude eks --exclude roles --exclude rds --exclude istio --exclude istio/helm_provider_deployment;\
 rsync -a templates/Jenkinsfile ${PRODUCTPATH}/;\
 rsync -a templates/eksIdentityMapping.yaml $(TF_ENV_CONFIG_DIR)/;\
	if [ -d "$(TF_INFRA_DIR)/resource/s3" ]; then \
	 echo 'not seeding s3 resource';\
	else\
	 rsync -a templates/resource/s3/* $(TF_INFRA_DIR)/resource/s3/;\
	fi
	@set -e; \
	if [ -d "$(TF_INFRA_DIR)/resource/rds" ]; then \
	 echo 'not seeding rds resource';\
	else\
	 rsync -a templates/resource/rds/* $(TF_INFRA_DIR)/resource/rds/;\
	fi
	@set -e; \
	if [ -d "$(TF_INFRA_DIR)/resource/eks" ]; then \
	 echo 'not seeding eks resource';\
	else\
	 rsync -a templates/resource/eks/* $(TF_INFRA_DIR)/resource/eks/;\
	fi
	@set -e; \
	if [ -d "$(TF_INFRA_DIR)/resource/roles" ]; then \
	 echo 'not seeding roles resource';\
	else\
	 rsync -a templates/resource/roles/* $(TF_INFRA_DIR)/resource/roles/;\
	fi
	@set -e; \
	if [ -d "$(TF_INFRA_DIR)/resource/istio" ]; then \
	 echo 'not seeding istio resource';\
	else\
	 rsync -a templates/resource/istio/* $(TF_INFRA_DIR)/resource/istio/;\
	fi
	@set -e; \
	if [ -f "$(TF_INFRA_DIR)/env/${ENV}/eksIdentityMapping.yaml" ]; then \
	 echo 'not seeding eksIdentityMapping.yaml';\
	else\
 	rsync -a templates/eksIdentityMapping.yaml $(TF_ENV_CONFIG_DIR)/;\
	fi
	@set -e; \
	if [ -f "$(TF_INFRA_DIR)/env/${ENV}/s3.tfvars" ]; then \
	 echo 'not seeding s3 tfvars';\
	else\
 	echo '###########################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/s3/README.md\n###########################################################\n\ns3 = {}' >$(TF_INFRA_DIR)/env/${ENV}/s3.tfvars;\
	fi
	@set -e; \
	if [ -f "$(TF_INFRA_DIR)/env/${ENV}/rds.tfvars" ]; then \
	 echo 'not seeding rds tfvars';\
	else\
 	echo '############################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/rds/README.md\n############################################################\n\nrds = {}' >$(TF_INFRA_DIR)/env/${ENV}/rds.tfvars;\
	fi
	@set -e; \
	if [ -f "$(TF_INFRA_DIR)/env/${ENV}/eks.tfvars" ]; then \
	 echo 'not seeding eks tfvars';\
	else\
 	echo '############################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/eks/README.md\n############################################################\n\n# space separated list in dependant order\nexternal_addons = ""\neks = {}' >$(TF_INFRA_DIR)/env/${ENV}/eks.tfvars;\
	fi
	@set -e; \
	if [ -f "$(TF_INFRA_DIR)/env/${ENV}/roles.tfvars" ]; then \
	 echo 'not seeding roles tfvars';\
	else\
 	echo '############################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/roles/README.md\n############################################################\n\nroles = {}' >$(TF_INFRA_DIR)/env/${ENV}/roles.tfvars;\
	fi
	@set -e; \
	if [ -f "$(TF_INFRA_DIR)/env/${ENV}/istio.tfvars" ]; then \
	 echo 'not seeding istio tfvars';\
	else\
  echo '############################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/istio/README.md\n############################################################\n\ncluster_name = null\nenabled_namespaces = "istio-system default"\nenable_pod_security_administration = false' >$(TF_INFRA_DIR)/env/${ENV}/istio.tfvars;\
	fi
endif




# init-config target is to be run only on initial bootstrap (not updates)
init-config:
	mkdir -p $(TF_ENV_CONFIG_DIR)
	rsync -a templates/* $(TF_INFRA_DIR) --exclude eksIdentityMapping.yaml --exclude state --exclude resource/s3 --exclude resource/rds --exclude resource/eks --exclude resource/roles
	rsync -av templates/.??* $(TF_INFRA_DIR)
	@if [ -d "$(TF_RESOURCE_DIR)/s3" ]; then \
	 echo 'not seeding s3 resource';\
	else\
	 rsync -a templates/resource/s3/* $(TF_INFRA_DIR)/resource/s3/;\
	fi
	@if [ -d "$(TF_RESOURCE_DIR)/rds" ]; then \
	 echo 'not seeding rds resource';\
	else\
	 rsync -a templates/resource/rds/* $(TF_INFRA_DIR)/resource/rds/;\
	fi
	@if [ -d "$(TF_RESOURCE_DIR)/eks" ]; then \
	 echo 'not seeding eks resource';\
	else\
	 rsync -a templates/resource/eks/* $(TF_INFRA_DIR)/resource/eks/;\
	fi
	@if [ -d "$(TF_RESOURCE_DIR)/roles" ]; then \
	 echo 'not seeding roles resource';\
	else\
	 rsync -a templates/resource/roles/* $(TF_INFRA_DIR)/resource/roles/;\
	fi
	@echo '##########################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# ${ENV} TERRAFORM BACKEND\n##########################' >$(TF_ENV_BACKEND)
	@echo '############################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# ${ENV} COMMON TF VARIABLES\n#\n# DO NOT EDIT THIS FILE\n# USE RESOURCE SPECIFIC VARS\n############################\n' >$(TF_ENV_VARS_COMMON)
	cat templates/state/common.vars.template >>$(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__ENVIRONMENT__/${ENV}/g' $(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__REGION__/${REGION}/g' $(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__PRODUCT__/${PRODUCT}/g' $(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__OWNER__/${OWNER}/g' $(TF_ENV_VARS_COMMON)
	$(SED_CMD) 's/__INITIAL_SRE__/${SRE}/g' $(TF_ENV_VARS_COMMON)
	rsync -a templates/eksIdentityMapping.yaml $(TF_ENV_CONFIG_DIR)/
	echo '###########################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/s3/README.md\n###########################################################\n\ns3 = {}' >$(TF_INFRA_DIR)/env/${ENV}/s3.tfvars
	echo '############################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/rds/README.md\n############################################################\n\nrds = {}' >$(TF_INFRA_DIR)/env/${ENV}/rds.tfvars
	echo '############################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/eks/README.md\n############################################################\n\n# space separated list in dependant order\nexternal_addons = ""\neks = {}' >$(TF_INFRA_DIR)/env/${ENV}/eks.tfvars
	echo '############################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/roles/README.md\n############################################################\n\neks = {}' >$(TF_INFRA_DIR)/env/${ENV}/roles.tfvars
	echo '############################################################\n# BOOTSTRAP VERSION: ${BOOTSTRAP_VERSION}\n# add additional vars here as needed\n# reference input configuration ../../resource/istio/README.md\n############################################################\n\ncluster_name = null\nenabled_namespaces = "istio-system default"\nenable_pod_security_administration = true' >$(TF_INFRA_DIR)/env/${ENV}/istio.tfvars

bootstrap-failed: check-bootstrap check-region check-product check-owner check-env check-outpath check-sre bootstrap-failed-commit
	@echo Creating base config for environment ${ENV}......

bootstrap: check-bootstrap check-region check-product check-owner check-env check-outpath check-sre commit
	@echo Creating base config for environment ${ENV}......

init:
	terraform init

cleanup:
	-rm terraform.tfplan
	-rm terraform.tfstate

plan: check-bootstrap cleanup init-config init
	terraform plan -var-file=$(TF_ENV_VARS_COMMON) -var region=${REGION} -var environment=${ENV} -var mcrypt_key=${MCRYPT_KEY} -compact-warnings -out=$(TF_PLAN)

destroy-failed:
	terraform destroy -var-file=$(TF_ENV_VARS_COMMON) -var region=${REGION} -var environment=${ENV} -var mcrypt_key=${MCRYPT_KEY}

destroy: restore-state
	terraform init
	terraform destroy -var-file=$(TF_ENV_VARS_COMMON) -var region=${REGION} -var environment=${ENV} -var mcrypt_key=${MCRYPT_KEY}
	-cd $(TF_INFRA_DIR); git rm -rf ${ENVDIRPATH}; git rm -rf ${STATEFILEPATH}/${AWS_ACCOUNT}/${ENV}.terraform.tfstate.ENCRYPTED
	-cd $(TF_INFRA_DIR); rm -rf ${ENVDIRPATH}; rm -rf ${STATEFILEPATH}/${AWS_ACCOUNT}/${ENV}.terraform.tfstate.ENCRYPTED

apply: plan
	terraform apply $(TF_PLAN)

config-update: apply
	@if [ $(shell uname) = "Darwin" ]; then\
	  echo bucket = $$(terraform output s3_bucket_id)>>$(TF_ENV_BACKEND);\
	  echo region = \"$${REGION}\">>$(TF_ENV_BACKEND);\
	  echo backend_unique_id = $$(terraform output unique_id)>>$(TF_ENV_VARS_COMMON);\
	else\
	  echo bucket = \"$$(terraform output s3_bucket_name)\">>$(TF_ENV_BACKEND);\
	  echo region = \"$${REGION}\">>$(TF_ENV_BACKEND);\
	  echo backend_unique_id = \"$$(terraform output unique_id)\">>$(TF_ENV_VARS_COMMON);\
	fi

commit: config-update
	-mkdir -p ${STATEPATH}/${AWS_ACCOUNT}
	$(MCRYPT_CMD) <terraform.tfstate >${STATEPATH}/${AWS_ACCOUNT}/${ENV}.terraform.tfstate.ENCRYPTED
	@echo NEW FILES HAVE BEEN ADDED TO YOUR SOURCE REPO $(TF_INFRA_DIR), YOU MUST ADD COMMIT THEM
	cd $(TF_INFRA_DIR);git add Makefile;git add README.md;git add state/* -f;git add env/${ENV}/* -f;git add resource/*

bootstrap-failed-commit: init
	-rm terraform.tfplan
	terraform plan -var-file=$(TF_ENV_VARS_COMMON) -var region=${REGION} -var environment=${ENV} -var mcrypt_key=${MCRYPT_KEY} -compact-warnings -out=$(TF_PLAN)
	terraform apply $(TF_PLAN)
	-mkdir -p ${STATEPATH}/${AWS_ACCOUNT}
	$(MCRYPT_CMD) <terraform.tfstate >${STATEPATH}/${AWS_ACCOUNT}/${ENV}.terraform.tfstate.ENCRYPTED
	@echo NEW FILES HAVE BEEN ADDED TO YOUR SOURCE REPO $(TF_INFRA_DIR), YOU MUST ADD COMMIT THEM
	cd $(TF_INFRA_DIR);git add Makefile;git add README.md;git add state/* -f;git add env/${ENV}/* -f;git add resource/*

update-bootstrap: check-bootstrap check-region check-env update-commit

restore-state: check-bootstrap
	$(MCRYPT_CMD) -d <${STATEPATH}/${AWS_ACCOUNT}/${ENV}.terraform.tfstate.ENCRYPTED >terraform.tfstate

update-plan: check-bootstrap cleanup restore-state check-env check-region seed-resources
	terraform init
	terraform plan -var-file=$(TF_ENV_VARS_COMMON) -var region=${REGION} -var environment=${ENV} --var mcrypt_key=${MCRYPT_KEY} -compact-warnings -out=$(TF_PLAN)

update-apply: update-plan
	terraform apply $(TF_PLAN)

update-commit: update-apply
	-mkdir -p ${STATEPATH}/${AWS_ACCOUNT}
	$(MCRYPT_CMD) <terraform.tfstate >${STATEPATH}/${AWS_ACCOUNT}/${ENV}.terraform.tfstate.ENCRYPTED
	@echo UPDATED FILES HAVE BEEN ADDED TO YOUR SOURCE REPO $(TF_INFRA_DIR), YOU MUST ADD COMMIT THEM
	cd $(TF_INFRA_DIR);git add Makefile;git add README.md;git add state/* -f;git add env/${ENV}/* -f;git add resource/*

reset-mcrypt-plan:
	terraform init
	export MCRYPT_KEY=${NEW_MCRYPT_KEY}; terraform plan -var-file=$(TF_ENV_VARS_COMMON) -var region=${REGION} -var environment=${ENV} --var mcrypt_key=${NEW_MCRYPT_KEY} -out=$(TF_PLAN)

reset-mcrypt-key: cleanup restore-state reset-mcrypt-plan reset-mcrypt-commit

reset-mcrypt-commit: update-apply
	-mkdir -p ${STATEPATH}/${AWS_ACCOUNT}
	export MCRYPT_KEY=${NEW_MCRYPT_KEY}; mcrypt <terraform.tfstate >${STATEPATH}/${AWS_ACCOUNT}/${ENV}.terraform.tfstate.ENCRYPTED
	@echo *******************************************************************************************************************
	@echo *** YOUR BOOTSTRAP STATE FOR ${ENV} WAS JUST UPDATED AND ENCRYPTED WITH A NEW MCRYPT KEY
	@echo *** MAKE SURE TO UPDATE YOUR LOCAL MCRYPT_KEY ENVIRONMENT VARIABLES AND PIPELINE SECRETS WITH NEW MCRYPT_KEY
	@echo *******************************************************************************************************************

tflint: init
	terraform fmt -recursive -diff -check
	tflint --ignore-module tools

help:
	@echo PREREQUISITES:
	@echo
	@echo mcrypt MUST be installed to run bootstrap make targets! On the mac, "brew install mcrypt"
	@echo MCRYPT_KEY environment variable must be set or passed in when calling this file. The value can be any random string. It is used to generate the mcrypt hash used to encrypt and decrypt the terraform state file. You need to run the reset-mcrypt-key target if you need to change it.
	@echo MCRYPT_KEY environment variable must be set or passed in when calling this file. The value can be any random string. It is used to generate the mcrypt hash used to encrypt and decrypt the terraform state file. You need to run the reset-mcrypt-key target if you need to change it.
	@echo
	@echo USER TARGETS:
	@echo plan             - run terraform plan for an environment not yet bootstrapped
	@echo bootstrap        - create terraform scaffolding for an environment. Target will create resources and generate state and tf files at PRODUCTPATH
	@echo update-plan      - run terraform plan a previously bootstrapped environment, used to preview changes to the environments terraform scaffolding
	@echo update-bootstrap - update a terraform scaffolding on previously bootstrapped environment. Target will create/update/remove resources
	@echo destroy          - un-bootstrap an environment. Target will destroy resources including backend terraform state so USE CAUTION!
	@echo destroy-failed   - cleanup failed bootstrap
	@echo tflint           - run a terraform formatting and linting recursively
	@echo reset-mcrypt-key - run this when you need to change the encryption key for terraform state. The state file will get re-encrypted so USE CAUTION!
