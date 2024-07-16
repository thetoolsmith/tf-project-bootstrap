## About
This directory contains the installers and configuration for deploying external add-ons to eks clusters.
Files here are meant to be invoked from the root of this repo terraform/Makefile.

## Installer
This is the **entry point** which is invoked from terraform/Makefile.
There are 3 make targets for managing the deployment of these external addons with installer. Examples are shown below.

### Deploy external addons to eks clusters
```
make REGION=us-east-1 ENV=qa RESOURCE=eks eks-ext-addons-deploy
```

### Remove external addons from eks clusters
```
make REGION=us-east-1 ENV=qa RESOURCE=eks eks-ext-addons-remove
```

There is also a make target for verifying the deployments on all clusters.

### Verify external addons on all eks clusters
```
make REGION=us-east-1 ENV=qa RESOURCE=eks eks-ext-addons-verify
```

Each of the above make targets will get the terraform output for the eks components and iterate over the list of cluster names that are being managed by the eks terraform, and call the installer. This way we do not have to hard code cluster names or number or region of the cluster. It's all dynamic.

The installer will determine which external addons to deploy and in what order based on the external_addons configuration value in ```terraform/env/~ENV~/eks.tfvars``` Refer to [Install and Remove sequence](README.md#install-and-remove-sequence-(external_addons-input-variable))

## External Addons
Within this add-ons directoy, there will be a shell executor for each external addon supported with each release version of bootstrap.
The current list includes add-ons for Istio.
This is an opinionated implementation of Istio where we use AWS ACM-PCA for generating server certifcates for Istio. 
- cert-manager [required for istio]
- aws-privateca-issuer [required for istio]
- istio-csr [required for istio]

Each addon executor is specific to installing, verifying and removing that addon only.
The external addon (referred to as external addon because it's not deployed as part of the cluster configuration in eks.tfvars) executor may need additional files for deployment of the addon. In this case you will see a directory here as well in the name of the executor script.

> **Note** The eks-load-balanacer-controller addon is deployed via terraform unlike the rest of the adddons which mainly use scripts helm deployment.
> eks-load-balancer-controller does get deployed via helm_release within the terraform plan. As such, it is a special add-on and not deployed with the eks-ext-addons-deploy Make target.

## Install and Remove sequence (external_addons input variable)
The external_addons configuration input variable is auto-generated at bootstrap as empty string.
It is located with the rest of your eks terraform input variables at ```terraform/env/~ENV~/eks.tfvars```
external_addons is a space separated list of external addon/plugins supported and that you wish to deploy to your clusters.

### Example configuration
```
external_addons = "cert-manager aws-privateca-issuer istio-csr"
```

> **Tip** Enter the addon names in the order that you wish to have them deployed. Some addons will have dependencies and thus the deploy sequence depends on the order of this list.
> On remove, the ordered list will be uninstalled in reverse.

## Prerequisites
For installer to work properly, you will need to pass in the parameters as noted in the file [installer](installer).
The environment variable **ENV** must also be set. This would be set automatically if installer is invoked from terraform/Makefile as it is intended.
The aws REGION and associated kubectl config will be set dynamically in the file [installer](installer).

Current supported regions include
- us-east-1
- us-east-2
- us-west-1
- us-west-2

The installer and each addon executor documents what other tools may be required in your localdev or pipeline environment.

