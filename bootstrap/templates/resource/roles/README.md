## About
This template is used to deploy AWS Roles for existing eks clusters.

The template works for one cluster at a time. You need to run this terraform plan once for each cluster you wish to deploy the Roles for.
Each run of this plan with a different cluster name will create role tfstate for that cluster only. Therefore, you need to manage the correct tfstate backend configuration and key before running this plan.
Refer to how this is being done in the [Makefile](./Makefile) 

## Requirements
You must preset kubeconfig to the correct context before applying this module. This is needed because we need to dynamically get the oidc provider for each cluster. We use data source for that.

You also need to be authenticated to aws with the proper credentials for managing the eks cluster.
This includes setting the correct AWS IAM and REGION.
S3 backend configuration must be in place.

## Configuration format and example
```
roles = {
  eks_secrets = {
    statements = [
      {
        effect = "Allow"
        actions = [
          "secretsmanager:List*",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:GetRandomPassword",
          "secretsmanager:ListSecrets"
        ]
        sid = "secretslistread"
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        sid       = "secretsread"
        resources = ["*"]
      },
      {
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        sid = "kmsdecrypt"
        resources = ["*"]
      }
    ]
  }
}
```

## Example targets

### Plan (verify)
make REGION=us-east-1 ENV=dev CLUSTER_NAME=my-eks-cluster plan

### Apply (deploy)
make REGION=us-east-1 ENV=dev CLUSTER_NAME=my-eks-cluster apply

### Destroy (remove)
make REGION=us-east-1 ENV=dev CLUSTER_NAME=my-eks-cluster destroy


