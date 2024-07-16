# Setup localmachine (dev) environment

## List of required tools and utilities to run all mare tagets
[Required tools](../README.md#list-of-tools-and-utilities-needed-to-run-bootstrap-make-targets)

In order to execute any targets in Makefile locally, you will need to have the required utilities and aws client configurations.
These terraform templates that have been provided in the resource/ directory require AWS SSO IAM login configurations for multiple accounts. The terraform files contain numerous **aws provider configurations** to support cross region and cross account infrastructure provisioning (aka deployment).

These make targets will execute terraform plans with the current context AWS IAM Login. In other words, you need to be authenticated and logged into AWS with an account prior to running ay make targets. When these terraform plans are executed via pipeline (GHA, Jenkins etc....), the same requirment exists. 

You can bootstrap and deploy to multiple different environments (ENV) within a single IAM account. In other words there does not have to be a 1:1 mapping for IAM account and environment.
For example, with these re-usable Terraform plans, you could bootstrap and deploy resources to "dev" or "qa" etc... all within a single IAM account.
We've abstracted the environment from the IAM account being used. Thus, an environment in this context is a logical separation of resources within a single IAM account.
Having this ability will allow multiple environments within one IAM for testing different versions or software deployments etc..

## Local aws config and credential accounts needed
The following is a suggested way to setup your local IAM AWS creds, but any method that allows these terraform plans to use multiple accounts will be fine. These setups are needed to run the various terraform make targets in the Makefile from localmachine. If you only plan to run these from a pipeline, not need for multiple local aws credentials setup.

### Install aws-cli and aws sso utilities and setup local aws profiles and credentials

#### Installing utilities
[aws cli v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#:~:text=Command%20line-,installer,-%2D%20All%20users)

[aws-sso-util](https://github.com/benkehoe/aws-sso-util)

Install on Mac OS
```
python3 -m pip install --user aws-export-credentials
```

[aws-export-credentials](https://github.com/benkehoe/aws-export-credentials)

Install on Mac OS
 ```
brew install aws-export-credentials
```

#### Configure aws-sso-util and aws/config profiles
The 2 aws sso utilities described about have some commands in the documentation that can help you setup properly. For example, this command will prompt you for information and create the aws/config profile.
```
aws-sso-util configure profile YOUR_PROFILE_NAME
```

The profile should look like this with values corrosponding to what you entered
```
[profile playground]
sso_start_url = https://MYORG.awsapps.com/start
sso_region = us-east-1
sso_account_id = xxxxxxxxxxx
region = us-east-1
credential_process = aws-sso-util credential-process --profile dev
sso_role_name = AWS-Eng-Amin-Dev
output = json
```

> **TIP** you can always create the profiles manaully if you choose.

Then you would do something like this to login using aws-sso-util
```
export AWS_PROFILE=YOUR_PROFILE_NAME
export AWS_ACCOUNT=xxxxxxxxxx
aws-sso-util login
```

Then you would use aws-export-credentials to get an sso token based on a specific profile config. Similar to this
```
aws-export-credentials --profile YOUR_PROFILE_NAME
```

To fully auotmated this so that the sso token retreival can happen programmatically, use a bash profile (or other) to run these two utilities to get sso tokens refreshed by simply running a bash profile script.
You don't want to have to get new tokens via the aws console or other means manually everytime it expires or you want to switch aws login accounts.

> **Note** Some terraform templates have the ability to switch accounts and regions as needed during runtime. It does this by way of Terraform provider alias and the process is automated by terraform under the hood. When terraform is running and it needs to use a different provider, that provide alias must be configured (this is done and is already baked into the resource terraform templates in providers.tf).
However, You MUST have the aws profile configured in ~/.aws/config.

Example script to automaticallly run aws-export-credentials so that getting new tokens will be automatic. I beleive terraform is also using the same sso get token api under the hood.

Below is a shell script that can be run from a bash shell that will get updated sso tokens whenever its run for a specific aws profile you already had configured in ~/.aws/config

```
export profile=$1
profile() {
export AWS_PROFILE=$profile
case $profile in
  dev)
    export AWS_ACCOUNT=xxxxxxxxxxxx
    ;;
  devother)
    export AWS_ACCOUNT=xxxxxxxxxxxx
    ;;
esac
}
profile

login() {
aws-sso-util login
exportCreds
}
exportCreds() {
aws-export-credentials --profile dev --credentials-file-profile dev;
}
login
aws sts get-caller-identity
```

Your could run this from a bash profile
```
source ~/.aws_login playground
```

# Using Makefile to deploy terraform resources
Now that you have installed the prerequisites and setup aws authentication on your localmachine, you are ready to start deploying resources.

## Setting correct kubeconfig
In order for these TF templates to run in pipelines, we need to use a localized kube config file that can be resolved from a known location. We use the terraform directory for this. It is the *working directory**

You need to set the following environment variable when running these templates locally as well. This will assure all the addon scripts, TF templates using helm and anything else that needs it will find it.
```
KUBECONFIG="../../.kube/config"
```

## MAKE COMMANDS

## ABOUT Arguments
These variables can be preset in the shell or passed into make when executing targets. Must be set for all targets in this Makefile
```
REGION=us-east-1 (TIP: THIS IS THE BASE REGION WHERE TF STATE IS STORED. NOT RELATED TO REGION THE RESOURCE IS BEING DEPLOY TO)

ENV=qa (whatever the name is of a bootstrapped environment. You can have any number of bootstrapped environments in the repo (per product repo. However, only one product should be specified per code repository).

RESOURCE=eks (supported resource type. Currently we support s3 and eks for the time being).
```

## PLAN (VERIFY) a resource type (required vars set in call)
```
make REGION=us-east-1 ENV=dev RESOURCE=s3 plan
```

## APPLY (DEPLOY) a resource type (required vars set in call)
Terraform apply will process the terraform.tfstate and create, update or remove applicable resouces and/or configuration.
```
make REGION=us-east-1 ENV=dev RESOURCE=s3 apply
```

## DESTROY (REMOVE) a resource type (required vars set in call)
```
make REGION=us-east-1 ENV=dev RESOURCE=s3 destroy
```

## DEPLOY SEQUENCE for EKS clusters with Istio integration
The following shows the install/deploy sequence for getting eks clusters deployed with Istio enabled

### PLAN eks clusters (uses env/__ENV__/eks.tfvars for configuration)
```
make REGION=us-east-1 ENV=dev RESOURCE=eks plan
```

### APPLY eks clusters
```
make REGION=us-east-1 ENV=dev RESOURCE=eks apply
```

### DEPLOY eks cluster load-balancer-controller (uses aws/eks module in terraform helm_release)
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-lb-controller-apply
```

### VERIFY eks cluster load-balancer-controller (uses aws/eks module in terraform helm_release)
This will run terraform plan as well as verify deployment in the cluster
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-lb-controller-apply
```

### REMOVE eks cluster load-balancer-controller (uses aws/eks module in terraform helm_release)
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-lb-controller-destroy
```

### DEPLOY eks cluster external add-ons (uses external_addons in env/__ENV__/eks.tfvars for configuration)
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-ext-addons-deploy
```

### VERIFY eks external_addons
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-ext-addons-verify
```

### REMOVE eks cluster external add-ons (uses external_addons in env/__ENV__/eks.tfvars for configuration)
Removes in reverse order as listed in external_addons
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-ext-addons-remove
```

### DEPLOY Istio
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-istio-deploy
```

## REMOVE an eks cluster already deployed
This scenario only involves editing the eks.tfvars file to remove the cluster config, region etc... that you wish to remove.
Run the same above plan and apply targets and terraform will remove all resources related to you eks.tfvars changes.

## REMOVE Istio
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-istio-remove
```

## Note about eks external_addons
In the external_addons value in env/__ENV__/eks.tfvars, you list the add-ons in dependant order of Install.
When removing these, the script will remove them in reverse order with the following make command
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-ext-addons-remove
```

> **Note** The current tooling treats all external_addons as a **single** resource. Thus, the list gets processed the same for install and remove, but in reverse when removing.
> **TBD** We need to add a method of removing 1 external_addons without having to remove all, then re-install the updated list.

# Issues and notes

## Using default tags
We attempted to use default_tags {} in providers {} block now that it is supported. This would allow us to configure required tags in one place and have that be applied to all resoources where the provider is used. 
However, each tag in the map will always show as a change in terrform plan output. This is a known issues and thus not recommended to use default_tags.
We still use required_tags and optional_tags merged map for all resources, we just need to pass this into the resource configuration instead of relying on the provider default_tags.
[Reference issue](https://github.com/hashicorp/terraform-provider-aws/issues/18311)


