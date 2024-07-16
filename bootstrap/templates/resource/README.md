# Make sure you have setup your local development environment. [Example reference](../README.md)

## About resources
This resource directory was seeded as part of the [Environment Bootstrap](../../README.md).
The terrform templates located at ```/terraform/resource/``` are meant to be give you everything you need to starting deploying supported resources.

As a user of this system, you create your input terraform variables in the resource tfvars files created in terraform/env/ENV/*resource-name*.
```
s3.tfvars
rds.tfvars
eks.tfvars
...
...
...
```
Example inputs are shown in next sections.

Updates to a bootstrapped environment (make update-bootstrap), or bootstrapping another environment  will **NOT** overwrite or change any files in the /terraform/resource directory orn the terraform/env/ directory. These are templates and seeded as a one time thing during the initial (first) environment bootstrap for the product/app/service.

## Regions
This current poc supports 4 regions, but more can be added when needed
1. us-east-1
1. us-east-2
1. us-west-1
1. us-west-2

## About multi region resource deploys (s3)
The s3.tfvars file contains an empty s3 configuration. You add s3 configuration here for each s3 bucket you wish to deploy to any supported region.

Replica's are created in the same region (for now). There's a limitation on modules that have for_each, count or provider configuration properties.
[reference](https://github.com/hashicorp/terraform/issues/24476)

The s3 input variable is a complex object. Refer to s3/vars.tf for the object type definition as well as the [S3 Example Inputs](s3/README.md#example-s3-input-configuration)

## About multi region resource deploys (eks)
Node groups are not yet implemented for the inputs. Will be added at some point.
This goes for both self managed and eks managed. To add support for that, refer to [this page](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)

### Example eks input configuration
[EKS Example Inputs](eks/README.md#example-eks-input-configuration) shows the tf variable input for creating 2 clusters.

### Additional eks variables
There will be more eks configuration variables that will be exposed for consumer at some point.

There can also be some **hidden** inputs that can be set. However, setting these to something that is not the default should most likely require security review.
These **hidden** eks cluster configuration variables are shown below
```
eks = {
  CLUSTER_NAME = {
    enable_public_access = false //setting this to true should require security review
  }
}
```

## Istio deploy
Using tetrate distro
[Reference](istio/README.md)

### Deploy (istio)
```
make REGION=us-east-1 ENV=qa RESOURCE=eks istio-deploy
```

### Remove (istio)
```
make REGION=us-east-1 ENV=qa RESOURCE=eks istio-remove
```

> **Tip** In this implementation we specify eks as the resource and call special istio targets. This deploy is meant to deploy istio to all clusters provisioned in the same project bootstrap.
> This is how we dynamically get the cluster names for all clusters deployed that should have istio deployed.
> Looking at the [Makefile](../Makefile) for these targets you will see that we cd into the resource/eks directory, run terraform plan to generate the outputs needed to supply to the istio resource inputs. This way we do not need to know all the clusters that were deployed and hard code that into source control. We simply get the cluster_names from the terraform outputs for eks resource plan.
> We then iterate over that list of cluster names and call the resource/istio/wrapper.sh which gets the aws region from the region short name in the clustername. The script then generates the appropriate kubeconfig for the cluster we will attempt to deploy Istio.


## AWS Provider default tags always show as changes in terraform plan
[REF](https://github.com/hashicorp/terraform-provider-aws/issues/18311)

## terraform public module error
Opened issue on terraform/aws_eks module

[REF](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2423)

## Terraform modules do not support lifecycle
[4th highest voted TF Open Issue](https://github.com/hashicorp/terraform/issues/27360)


