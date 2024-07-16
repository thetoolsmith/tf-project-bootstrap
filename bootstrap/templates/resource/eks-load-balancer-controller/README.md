## About
This module is used to deploy eks-load-balancer-controller addon to existing eks cluster.
It use the public aws/eks submodule [eks-load-balancer-controller](https://registry.terraform.io/modules/lablabs/eks-load-balancer-controller/aws/latest?tab=inputs)

This module works with one cluster at a time. You need to run this terraform plan once for each cluster you wish to deploy the lb-controller to.
Each run of this plan with a different cluster name will create tfstate for that cluster only. Therefore, you need to manage the correct tfstate backend configuration and key before running this plan.
Refer to how this is being done in the [Makefile](./Makefile) 

## Requirements
You must preset kubeconfig to the correct context before applying this module.
You also need to be authenticated to aws with the proper credentials for managing the eks cluster.
This includes setting the correct AWS IAM and REGION.
S3 backend configuration must be in place.

## Example targets

### Plan (verify)
make CLUSTER_NAME=my-eks-cluster plan

### Apply (deploy)
make CLUSTER_NAME=my-eks-cluster apply

### Destroy (remove)
make CLUSTER_NAME=my-eks-cluster destroy

