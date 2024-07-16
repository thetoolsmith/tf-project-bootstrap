# About
This is a terraform bootstrapping tool for deploying infrastructure via terraform to AWS.
Currently the only way to use this tool is to clone this repo locally.
We may implement another method of distribution, but that is tbd.

Bootstrap is combination of two things
1. Starting point for provisioning and deploying AWS resources with Terraform at scale across teams, products, verticals and environments. It does two things at the high level.
    1. setup terraform foundation aws resources for terraform backend state (per product/environment s3 tfstate bucket), kms key and dynamo table for locking state alog with some important Secrets Manager secrets. This provides the launching pad for teams/consumers to deploy resources with preconfigured state backends, secrets to hold bootstrap output data and a simple command interface (Makefile)
    1. Populates the destination repo (the repo being bootstrapped) with pre-built terraform resource templates. Provides Ready-To-Use terraform for deploying resources at scale across teams, products, verticals and environments. These templates are built to be 100% dynamic. They use discovery tech niques over hardcoded ids, arns etc....whenever possible. Thus, the template may appear to be a bit complex to novice Terraform users. However the intent is to use these as is and not require users of this provisioning automation to learn or understand anything beyond basic entry level terraform knowhow. The complexity falls on the core template and module maintainers. These are the folks that should have deep understanding of Terraform and building things with re-usable scalable templates.

# Setup local dev environment
In order to execute any targets in the bootstrap Makefile as well as the terraform/resource/Makefile locally, you will need to have the required utilities and aws client configurations.
These terraform templates that have been provided in the resource/ directory require AWS SSO IAM login configurations for multiple accounts. The terraform files contain numerous **aws provider configurations** to support cross region and cross account infrastructure provisioning (aka deployment).

> **Tip** If your local aws config is in the default location ```~/.aws/config ~/.aws/credentials``` you will need to copy the config and credentials files into the terraform/ directory of your destination repo after bootstrapping.
> ```cd terraform && cp -R ~/.aws/ .aws/```

> **Note** This will allow you to run the terraform resource make targets locally. This requirement was added as a result of adding Jenkinfile pipeline support for running the terraform resource deploy targets. The terraform templates were updated to look in the /terraform/ root location for aws config profiles. The Jenkinsfile that is included in terraform/ directiory post bootstrapping shows how the aws config shared profile files are created dynamically in this location.
> In summary, when running locally, update these from you existing local aws config and credentials files, ***but do not check these files in***.

The bootstrap and terraform resource make targets will execute terraform context with the current context AWS IAM Login. In other words, you need to be authenticated and logged into AWS with an account prior to running ay make targets. When these terraform plans are executed via pipeline (such as GHA or Jenkins), the same requirment exists.

You can bootstrap and deploy to multiple different *environments* within the IAM playground account. In other words there does not have to be a 1:1 mapping for IAM account and environment.
For example, when consuming these re-usable Terraform plans, you could bootstrap and deploy resources to *dev* or *qa* etc... all within the playground IAM account.
We've abstracted the environment from the IAM account being used. Thus, an environment in this context is a logical separation of resources within a single IAM account.
Having this ability will allow teams to have multiple **environments** within playground for testing different versions or software deployments.

## Local aws config and credential accounts needed
Assuming you are testing and deploying from localmachine with IAM account IAM from local dev machines, you should uae the following uilities of similr to setup your aws config and credentials file.

[aws cli v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#:~:text=Command%20line-,installer,-%2D%20All%20users)

[aws-sso-util](https://github.com/benkehoe/aws-sso-util)

Install on Mac OS
```
brew install aws-sso-util
```

[aws-export-credentials](https://github.com/benkehoe/aws-export-credentials)

Install on Mac OS
 ```
python3 -m pip install --user aws-export-credentials
```

#### Configure aws-sso-util and aws/config profiles
The 2 aws sso utilities described about have some commands in the documentation that can help you setup properly. For example, this command will prompt you for information and create the aws/config profile.
```
aws-sso-util configure profile YOUR_PROFILE_NAME
```
You can either run this above command for you dev profile and any others you would need to access from your local machine, or enter the profile manually as shown below. 

The profile should look like this with values corrosponding to what you entered
```
[profile dev]
sso_start_url = https://your-org-sso.com/start
sso_region = us-east-1
sso_account_id = 111111111
region = us-east-1
credential_process = aws-sso-util credential-process --profile dev
sso_role_name = AWS-Eng-Admin-Dev
output = json
```

> **TIP** you can always create the profiles manaully if you choose.

Then you would do something like this to login using aws-sso-util
```
export AWS_PROFILE=YOUR_PROFILE_NAME
export AWS_ACCOUNT=1111111111
aws-sso-util login
```

Then you would use aws-export-credentials to get an sso token based on a specific profile config. Similar to this
```
aws-export-credentials --profile YOUR_PROFILE_NAME
```

**HOWEVER**, we want to fully auotmated this so the sso token retreival can happen programmatically.
To solve this, we use a bash profile to run these two utilities to get sso tokens refreshed by simply running a bash profile script.
You don't want to have to get new tokens via the aws console or other means manually everytime it expires or you want to switch aws login accounts.

> **Note** These terraform templates will switch accounts and regions as needed during runtime. It does this by way of Terraform provider alias and the process is automated by terraform under the hood. When terraform is running and it needs to use a different provider, that provide alias must be configured (this is done and is already baked into the resource terraform templates in files called providers.tf).
You MUST have the aws profile configured in ~/.aws/config.

You SHOULD also use this example script to automaticallly run aws-export-credentials so that getting new tokens will be automatic.

Below is a shell script that can be run from a bash shell that will get updated sso tokens whenever its run for a specific aws profile you already had configured in ~/.aws/config

```
export profile=$1
profile() {
export AWS_PROFILE=$profile
case $profile in
  dev)
    export AWS_ACCOUNT=111111111111
    ;;
  qa)
    export AWS_ACCOUNT=222222222222
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
```

A couple of things to note in the above shell script.

Your would run this to login to aws with dev IAM account and get a sso token refresh (assumes you put the script in a file names ~/.aws_login)
```
source ~/.aws_login dev
```

A similar output will b generated....
```
{
    "UserId": "989898989898987:first.last",
    "Account": "11111111111",
    "Arn": "arn:aws:sts::11111111111:assumed-role/AWSReservedSSO_AWS-Eng-Admin-Dev_xxxxxxxxxxxxx/first.last"
}
```

You can look in ~/.aws/credentials file and see an entry for each aws profile you ran aws-export-credentials for. The token will have an expiration.


## Setup, prerequisites and Usage
First thing you need to do if not already setup is create a github ssh key of type **Configure SSO**.
You'll need this to source terraform shared modules from git.

To create the github key go to your git profile | settings | SSH and GPG Keys | New SSH Key
The git ssh key should should be **Authentication Key** type and look something like ![this](example_git_ssh.png)


***You must have mcrypt installed locally to run bootstrap***

> **mcrypt** MUST be installed to run bootstrap make targets! On the mac, "brew install mcrypt"
> MCRYPT_KEY environment variable must be set or passed in when calling this file. The value can be any random string. It is used to generate the mcrypt hash used to encrypt and decrypt the terraform state file. You need to run the reset-mcrypt-key target if you need to change it.

### List of tools and utilities needed to run bootstrap make targets
1. terraform
1. tfswitch (optional)
1. mcrypt
1. sed
1. rsync
1. tflint
1. aws cli
1. jq
1. yq
1. kubectl
1. helm
1. istioctl

To begin using this Terraform provisioning tool, clone this repo to you local dev environment.
You also will need the bootstrap *destination* repo cloned locally as well. The destination repo is the repository that will contain the infrastructure provisioning terraform templates, encrypted bootstrapped environment tfstate and the ENV (you will specify in the bootstrap make commands) terraform variable input files. It could be an existing product/app or service repository (recommended), or a dedicated repo for the infrastructure.
This bootstrap tool is intended to create infrastructure provisioning code that will live in the same repo as the product,app or service it will create infrastructure for. But it's not a requirement.

> **Note** all files generated during bootstrap will be created in the destination repo under a new directory called **terraform** at the root of the repo.

Clone the bootstrap repo
```
git clone git@github.com:thetoolsmith/tf-project-bootstrap.git
```

Clone or create a new repo for bootstrapped files

While in the local cloned bootstrap repo root, checkout the release you want to use for bootstrapping. For specific release
```
git checkout 0.0.1 (or the latest version)
```

> **warning** you cannot run bootstrap while on main branch. There's some simple versioning that gets run on the templates once they are seeded into your consumer repo during bootstrap execution. The branch you're on will determine the version or the files.


# NOW YOU ARE READY TO GET STARTED WITH TERRAFORM

> **Tip** Start with the **plan** target which will show you what will be created when you run the **bootstrap** target

## BOOTSTRAP PARAMETERS
There are some required parameters that need to be passed into the bootstrap make target commands.
Some of these ***required parameters*** will be used to generate uniquness in aws resource naming. Having a few token values that are used to construct resource naming should provide uniqueness at scale as long as you follow this basic rule...

> **Tip** Only once can you boostrap the combination owner-product-environment-region within a given IAM account. These 4 values together with the IAM account being used to run boostrap and eventually your terraform resource deployments, should provide uniqueness within your team as well as accross the organization.

- REGION (aws region where the tf state will be stored. This is **NOT** the region for deploying resources)
- ENV (the environment name defined by you or your team's workflow. Could be dev, qa etc... It's open to the consumer what to call it)
- OWNER (this should be your team, or product owner or some more specific product team etc....)
- PRODUCT (this is the product/app/service name)
- SEED_RESOURCE (should leave set to true)
- PRODUCTPATH (relative path to your consumer/destination product repo.)
- SRE (name of your teams AWS group. This is for future use, so nothing happening with this at the moment)

> **Required** MCRYPT_KEY environment variable

> **About SEED_RESOURCE**. This tells bootstrap that you want to populate the resource templates into your consumer repo in addition to creating the base terraform aws resources. Once the bootstrap resource seed templates are in your consumer repo, they will not be overwritten when running bootstrap commands even if this is set to true. The only way to get newer boostrap seed resource is to remove the resource from your **infratructure/resource/THERESOURCE** directory.

> **Tip** Some of the above variables could be preset as shell ENV vars instead of passing on the make command line. However it would only make sense to do that for REGION since it refers to where your tf state bucket will be and wouldn't change. 


## COMMANDS (some targets in Makefile are not intended to be run directly)

### plan
Shows what will happen with terraform state when running bootstrap
```
make REGION=us-east-1 ENV=qa OWNER=devops PRODUCT=tfhello SEED_RESOURCE=true PRODUCTPATH="../tfhello/" SRE="AWS-Eng-Devops" plan
```

### bootstrap
run once per environment for the product/app or service. Creates aws resource needed to deploy stuff with terraform
```
make REGION=us-east-1 ENV=qa OWNER=devops PRODUCT=tfhello SEED_RESOURCE=true PRODUCTPATH="../tfhello/" SRE="AWS-Eng-Devops" bootstrap
```

### update-plan
shows what will happen with terraform state when running update-bootstrap on previously bootstrapped environment
```
make REGION=us-east-1 ENV=qa OWNER=devops PRODUCT=tfhello SEED_RESOURCE=true PRODUCTPATH="../tfhello/" SRE="AWS-Eng-devops" update-plan
```

### update-bootstrap
updates resources created from previous product env bootstrap
```
make REGION=us-east-1 ENV=qa OWNER=devops PRODUCT=tfhello SEED_RESOURCE=true PRODUCTPATH="../tfhello/" SRE="AWS-Eng-devops" update-bootstrap
```

### destroy
destroys a bootstraped environment and all resources created with bootstrap. Does **NOT** destroy product resources (s3, eks etc...) that have been deployed.

> **Note** Be aware that this command only tears down the terraform foundation resources such as the s3 bucket for tfstate.
> If you destroy a bootstrapped environment, you will also destroy the tfstate files that are in the bucket that contain state for all resources you have deployed.
> It is **HIGHLY RECOMMENDED** to run destroy on all your deployed resources for the given product and environment **BEFORE** running this destroy bootstrap.

```
make REGION=us-east-1 ENV=qa OWNER=devops PRODUCT=tfhello SEED_RESOURCE=true PRODUCTPATH="../tfhello/" SRE="AWS-Eng-devops" destroy
```

### destroy-failed
This target is meant to help cleanup after a failed bootstrap. Some resource may have been created and without a successfully completion of the bootstrap target, the state will not be processed fully. Therefore this target can be run and it will use the tfstate left over in this directory from the failed bootstrap.

```
make REGION=us-east-1 ENV=qa OWNER=devops PRODUCT=tfhello SEED_RESOURCE=true PRODUCTPATH="../tfhello/" SRE="AWS-Eng-devops" destroy-failed
```

## REPOSITORY MAINTAINER COMMAND

### version-bump
Target to bump bootstrap version when starting a new release branch. **For repo maintainer use only. This target is not meant for users of this tool**.
This target takes no arguments. Simply run the following command in the root of this repo with a version branch checked out.
For example, say you are on main branch and want to create a new version 0.0.8 because you just released and merged 0.0.7 to main. You would run the following
```
git checkout -B 0.0.8
make version-bump
git commit -am "version bump to 0.0.8"
git push origin 0.0.8
```

## About resources

> **WARNING** you cannot run any make targets when on main branch in this repo. The branch must be one of the release versions such as 0.0.1, 0.0.2 etc....

This resource directory was seeded as part of the environment bootstrap.
The terrform files here are meant to be give you everything you need to starting deploying supported resources.

As a consumer, you create your input terraform variables in the resource tfvars files in env/ENV/.
```
s3.tfvars
rds.tfvars
eks.tfvars
```
Example inputs are shown in next sections.

Updates to a bootstrapped environment (make update-bootstrap), or bootstrapping another environment  will **NOT** overwrite or change any files in this /resource directory. These are templates and seeded as a one time thing during the initial (first) environment bootstrap for the product/app/service.

## Regions
This current config supports 4 regions, but more can be added when needed
1. us-east-1
1. us-east-2
1. us-west-1
1. us-west-2

## About multi region resource deploys (s3)
The s3.tfvars file contains an empty s3 configuration. You add s3 configuration here for each s3 bucket you wish to deploy to any supported region.

Replica's are created in the same region (for now). There's a limitation on modules that have for_each, count or provider configuration properties.
[reference](https://github.com/hashicorp/terraform/issues/24476)

The s3 input variable is a complex object. Refer to s3/vars.tf for the object type definition as well as the example below in this doc.

### Example s3 input configuration
[S3 Example Inputs](templates/resource/s3/README.md#example-s3-input-configuration)

## About multi region resource deploys (eks)
Node groups are not yet implemented for the inputs. Will be added soon

This goes for both self managed and eks managed. When the time comes to add support for that in this poc, refer to the example on [this page](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)

### Example eks input configuration
[EKS Example Inputs](templates/resource/eks/README.md#example-eks-input-configuration) shows the tf variable input for creating 2 clusters.

### Additional eks variables
There will most liklely be more eks configuration variables that will be exposed for consumer to set as this poc moves to an implementation.

There will also be some **hidden** inputs that can be set. However, setting these to something that is not the default will most likely require security review and explanation.
These **hidden** eks cluster configuration variables are shown below
```
eks = {
  CLUSTER_NAME = {
    enable_public_access = false //setting this to true requires security review
  }
}
```
## AWS Provider default tags always show as changes in terraform plan
[REF](https://github.com/hashicorp/terraform-provider-aws/issues/18311)

## terraform public module error
Opened issue on terraform/aws_eks module

[REF](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2423)
