## Regions
This currently supports 4 regions, but more can be added when needed
1. us-east-1
1. us-east-2
1. us-west-1
1. us-west-2

## About multi region resource deploys (eks)
Node groups are not yet implemented for the inputs. Will be added soon, but for poc, no code to handle this yet.
This goes for both self managed and eks managed. When the time comes to add support for that, refer to the example on [this page](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)

## Example eks input configuration
The example below shows the tf variable input for creating 3 clusters and creating 2 IAM roles for each of the clusters. Cluster A deployed to two regions, Cluster B to one region. Cluster A has a special configuration to override the IAM roles resources. ***Refer to the Roles documentation below for specific on how the roles input var works.***
```
eks = {
  A = {
    version = "1.26"
    regions = ["us-east-1", "us-west-2"]
    kms_key_administrators = [
      "arn:aws:iam::xxxxxxxxxxxx:user/admin1",
      "arn:aws:sts::xxxxxxxxxxxx:assumed-role/_AWS_SSO_ASSUMED_ROLE__/user.name"
    ]
    enable_public_access = true
    enable_private_access = true
    eks_managed_node_groups = {
      worker = {
        use_custom_launch_template = false
        disk_size = 50
        enable_remote_access = true
        ssh_keyname = null
        source_security_group_ids = []
      }
    }
    eks_managed_node_group_defaults = {
      instance_types = []
    }
    roles_resource_overrides = {
      foobar = {
        foobarread = [
          "arn:aws:secretsmanager:us-*:__CLUSTER_IAM__:secret:some-secret/*",
          "arn:aws:secretsmanager:us-*:__CLUSTER_IAM__:secret:some-other-secret/*",
          "arn:aws:secretsmanager:us-*:__OTHER_IAM__:secret:external-secrets/shared-secrets/*"
        ]
        foobarlistread = []
      }
    }
    vpc_id = {
      us-east-1 = "vpc-xxxxxxxxxxxxxxxxx"
      us-west-2 = "vpc-xxxxxxxxxxxxxxxxx"
    }
    subnet_ids = {
      us-east-1 = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"]
      us-west-2 = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
    }
    cluster_addons = {
      coredns = {
        most_recent = true
      }
      kube-proxy = {
        most_recent = true
      }
      vpc-cni = {
        most_recent = true
      }
    }
  }
  B = {
    version = "1.26"
    regions = ["us-east-1"]
    kms_key_administrators = [
      "arn:aws:iam::xxxxxxxxxxxx:user/admin1",
      "arn:aws:sts::xxxxxxxxxxxx:assumed-role/__ASSUMED_ROLE__/user.name"
    ]
    enable_public_access = true
    enable_private_access = true
    eks_managed_node_groups = {
      worker = {
        use_custom_launch_template = false
        disk_size = 50
        enable_remote_access = true
        ssh_keyname = null
        source_security_group_ids = []
      }
    }
    eks_managed_node_group_defaults = {
      instance_types = []
    }
    roles_resource_overrides = {
      foobar = {
        foobarread = []
        foobarlistread = []
      }
    }
    vpc_id = {
      us-east-1 = "vpc-xxxxxxxxxxxxxxxxx"
      us-west-2 = "vpc-xxxxxxxxxxxxxxxxx"
    }
    subnet_ids = {
      us-east-1 = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"]
      us-west-2 = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
    }
    cluster_addons = {
      coredns = {
        most_recent = true
      }
      kube-proxy = {
        most_recent = true
      }
      vpc-cni = {
        most_recent = true
      }
    }
  }
}
roles = {
  foobar = {
    statements = [
      {
        effect = "Allow"
        actions = [
          "secretsmanager:List*",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue"
        ]
        sid = "foobarlistread"
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
        sid       = "foobarread"
        resources = [
          "arn:aws:secretsmanager:us-*:xxxxxxxxxxxxx:secret:some-secret/secretfoo",
          "arn:aws:secretsmanager:us-*:__CLUSTER_IAM__:secret:other-sercret/*"
        ]
      }
    ]
  },
  secrets = {
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
        resources = [
          "arn:aws:secretsmanager:us-*:xxxxxxxxxxxxx:secret:some-secret/secretfoo",
          "arn:aws:secretsmanager:us-*:__CLUSTER_IAM__:secret:other-sercret/*"
        ]
      },
        effect = "Allow"
        actions = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        sid = "kmsdecrypt"
        resources = [
          "arn:aws:kms:us-east-1:xxxxxxxxxxxx:key/xxxxxxxxxx-xxxxxxxx-xxxxxxxxx-xxxxxxxxx",
          "arn:aws:kms:us-*:xxxxxxxxxx:key/mrk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        ]
      }
    ]
  }
}


> **Note** Keep the CLUSTER_NAME as short as possible. There is a 38 char limit in wks cluster resource name in AWS. The actual name is constructed dynamically in the terraform code and will include the **owner**, **product**, **environment** and **region short**. This will not leave much chars left over for the configuration CLUSTER_NAME. We recommmend using A, B, C etc.... Remember the configuration is specific to enviromnment, product and team/owner, so you really wouldn't need to be deploying lots of different clusters for the same product. Deploying to multiple regions is a different thing and is a simple list configuration within the cluster configuration as shown in the example above.


### Additional eks variables
tbd....


## Special outputs
kubeconfig is a sensitive value, so by default terraform will not show this on the output. 
This eks resource plan will create the kubeconfig when creating the cluster. If you wish to verify that, you can run this in the local directory after terraform plan or apply
```
terraform output kubeconfigs
```

## Using public module for kubeconfig creation
We are using [this module](https://registry.terraform.io/modules/hyperbadger/eks-kubeconfig/aws/latest) currently.
This return a text stream of the created kubeconfig. Not a file.
The helm provider is istio tf plan requires a file however, so we also create the local file in the eks cluster at 
```
~/.kube/config
```

We could also not use the eks-kubeconfig module and just create the file ourseleves as shown in this [Terraform EKS Document](https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/guides/eks-getting-started)

## About roles input variable in eks.tfvars
Currently (as of June 13, 2023) there are three configuration variables in eks.tfvars. These are all empty variables when the repo/environment is first bootstrapped.
1. eks = {}
1. external_addons = ""
1. roles = {}

The **roles** input variable is a special case and has some complex and confusing logic around it when processed in the eks templates. There's some understanding that is needed in order to use this properly. This section of the documentation should explain how this works and how to use this in eks.tfvars to provide flexibility and a mostly dynamic configuration.

#### roles input variable
The configuration is where we defined the default roles that will get created for each cluster we have configured in eks input variable.
Other IAM roles not specific to eks can be created using the [roles resource template](../roles/).
The roles configured in eks.tfvars are IAM roles specifically for eks clusters access and operation. Therefore any roles defined in eks.tfvars will get created for all clusters defined in eks.tfvars and being managed by terraform.
Refer to the above configuration example for defining roles in eks.tfvars. The configuration does not have any optional parameters. Refer to the variable type definition [here](modules/shared_eks/vars.tf).

Multiple roles can be defined, each with multiple statements with standard AWS Policy requirements (effect, sid, actions, resources).
The roles configuration variable is a map where each key is the user defined name of the role. This *role name* should be a single short string describing the role purpose. It will become part of the aws provisioned resources along with the eks cluster name that it is for.

> **Tip** Take note of the replacement token values used in the configuration example above. __CLUSTER_IAM__ and __CLUSTER_NAME__. These will be replaced with actual values during terraform plan execution.

#### roles_resource_overrides (in eks variable, per cluster specific role resources)
The **roles_resource_overrides** configuration property in eks variable is designed to provide a mechanism to override the default resource list in each default role.
Each role defined in roles input variable will get created as configured for each cluster being provisioned. Each role can have one or more **policy statements**. These statements require a resoure list of target arns to provide permissions.

**roles_resource_overrides** provides additional flexability.

roles_resource_overrides is an optional configuration within the eks cluster config as shown in the variable definition [here](modules/shared_eks/vars.tf).

When using roles_resource_overrides remember this is an **overrides** value. You will be replacing the entire statement resource list from the default role you are configuring in here.

> **WARNING** The roles_resource_overrides has a caveat.
> If you set this is one cluster configuration to override certain resource targets for a specific role, you *MUST* also specify roles_resource_overrides in the other cluster configurations and set all role names and sids to empty. Even if you do not want to override any of the role config for the cluster, if you are setting roles_resource_overrides in any cluster in this single eks.tfvars config, you must also set it for the other clusters. This is the caveat with using this.
> The reason for this is the way the terraform plan code processes the eks variable. It iterates over all cluster config and they must be of the same type. Terraform forces the types to be the exact same for all objects in the map. This is how terraform always behaves when processing maps. Because of this native TF behavior, we cannot simply skip roles_resource_overrides in one cluster config if setting in another. Additionally we we have to have the exact same map keys in each nested map within roles_resource_overrides as well.
> TBD. There might be one optimization that could be done. If we change the iteration logic on these cluster configs in modules/shared_eks/roles.tf, we might be able to get away with just specifying roles_resource_overrides = {} in the clusters we do not want to override. Some refactoring is needed on that.

If a statement resource list in one of the default roles contains 3 resource arns, and you need to add another one specifically for one cluster you are provisioning, you would add that rolename as a key in the roles_resource_overrides map. You will then need to add the sid as a key in that nested map for the statement containing the resource list you want to replace. The sid key is a list where you define all the resource arns that you want as part of that statement for the default role. You can use the token replacement values __CLUSTER_IAM__ and __CLUSTER_NAME__ here as well.
**You also need to add the other statement sids (if the role has any) under this roles_resource_overrides.rolename as well. If you do not want to override these additional statement resource lists, simply set the value to an empty list **[]**.
So for each statement sid you want to override, you put the full list of resource arns that you desire. For the role that contains that statement, you define the additional statement resource lists as empty lists in roles_resource_overrides.rolename.sid.
By setting the statement resource lists that you do not want to override (this is only for roles that contain statement resource lists that you do want to override) to empty value, you tell the terraform template to just use the role statement default resource list.
This is all shown in the above configuration example for the **foobar** role. Check out the role definition, then take a look at cluster A configuration where we are setting roles_resource_overrides. You will see how we need to override vs retain resource lists for each statement.

> **Note** We considered making the roles_resource_overrides an **additional** value instead of override. This still is TBD. Switching the configuration type and purpose would allow for less user configuration (override requires taking the full list of default role statement resources and configuring it in roles_resource_overrides even if you just want to add additional resources to the default list). However, we would loose some flexability since we would not be able to remove any resources from the list in the default role statements. So for now, we have decided to keep the roles_resource_overrides **override** property.

#### how roles configuration is processed in eks terraform plan/template
There is some complex logic in the terraform code regarding how roles are processed. Keep in mind, this is only about the IAM roles as defined in eks.tfvars.
Additionally, some additional roles may get created automatically (I.E. without any user defined configuration in eks.tfvars) when the cluster is provisioned. 
***This section of the documentation refers only to the user defined roles in eks.tfvars.***

The terraform template code described here can be referenced in [this file](modules/shared_eks/roles.tf).

The terraform template takes the roles input configuration and passes it through to the eks module. After the clusters are created (region specific portion of the eks template), the roles variable will get evaluated. A local variable is created to be used as the for_each iterator on each resource that is needed for the role. There are multiple resources needed such as data sources to get the cluster oidc identity provider which is used in the role policy, along with the IAM role terraform resources.
This iterator local variable is where the complexity kicks in. The variable is an object that is not only used as the iterator in the for_each for data sources and resources, but also used to create the policy *statements* dynamically. This is where terraform really shines.

In addition to the dynamic *statements* for the policies for each role we are defining in eks.tfvars, the terraform code also replaces some *known token values* such as __CLUSTER_NAME__. These values are used to provide a mechanism for creating policy statement resource arns that include the newly provisioned cluster. Keep in mind, we are still in the terraform runtime that created the cluster, so taking the cluster oidc arn and hard coding it in some file checked into source code is not an option at this point during the terraform plan execution. We wouldn't want to do that anyway! These templates are built to avoid the need to hard code resource arns, ids etc... throughout a code base. We are using a dynamic discovery methodology instead.

Another bit of logic also takes place during the dynamic *statements* creation. This is the point where the code evaluates the eks input variable for each cluster definition and looks for the map key *roles_resource_overrides*.
If terraform finds a configuration for the role and sid during its rendering, the roles_resource_overrides value will replace the statement resource list that is defined in the role input variable.
This mechanism allows us flexibility where we can have default roles defined that simply get created for each cluster with possible resource arn list override for each or any statement defined in any of the default roles.

## Known issues
Listed below are some known issues with aws/eks terraform module

### AWS Provider default tags always show as changes in terraform plan
[REF](https://github.com/hashicorp/terraform-provider-aws/issues/18311)

### Terraform public eks module error
Opened issue on terraform/aws_eks module

[REF](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2423)

### Open issues with terraform providers

[HELM](https://github.com/hashicorp/terraform-provider-helm/issues/539)

### Deleting clusters takes forever due to nodegroup delete taking forever
There is a dependency chain as follows
cluster -> nodegroup -> securitygroup -> ENI (networkinterface)
When terraform destroy is run to delete a cluster that has been removed from config tf vars inputs, it may take a very long time. After some research, the resource that actually takes the long time is the node-group delete processes. Although the dependency chain seems to be honered, it seems that sometimes and/or under some conditions, the nodegroup remains in Deleting status for quite some time. This appears to have been related to the underlying aws api trying to delete the associated security group and the attached ENI's. 
You may need to go to the aws console and detach the eni, then remove it, then remove the security group I/O rules (2 sec groups), then delete the node group, then delete the cluster.
Just something to be aware of. This is NOT always the case. We have destroyed many eks clusters by running **terraform destroy** without issue.


## Other notes

### templating in shell
We could replace all the shell scripts for installing with a more structure python tool or something.
It's also possible to use ```helm template``` for generating the yaml files if format is acceptable to helm.

### cluster_addons config
With cluster_addons config block, some addons will require node_groups.
The github project has a closed issue stating that if the addon is a deployment, this will happen. [Reference](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1838)

### external_addons input variable
The external_addons configuration input variable is auto-generated at bootstrap as empty string.
This is a space separated list of external addon/plugins supported and that you wish to deploy to your clusters.

> **Tip** Enter the addon names in the order that you wish to have them deployed. Some addons will have dependencies and thus the deploy sequence depends on the order of this list.
> On remove, the ordered list will be uninstalled in reverse.

#### Example configuration
```
external_addons = "cert-manager aws-privateca-issuer istio-csr"
```

There are 3 make targets for managing the deployment of these external addons. Examples are shown below.

#### Deploy external addons to eks clusters
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-ext-addons-deploy
```

#### Remove external addons from eks clusters
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-ext-addons-remove
```

#### Verify external addons on all eks clusters
```
make REGION=us-east-1 ENV=dev RESOURCE=eks eks-ext-addons-verify
```

Refer to [external add-ons documentation](./add-ons/README.md) for more details.

### manage_aws_auth_configmap config
If setting this config
```
manage_aws_auth_configmap = true
```
with self_managed_node_groups, you'll also need to set this
```
create_aws_auth_configmap = true
```
eks_managed_node_groups creates this automatically. [Reference](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009)

## Some issues that have been addessed
Using the aws/eks module does not allow us to set ALL resource naming as we wish. The module itself uses prefix naming as input on SOME variable, but not all. Example error...
│ 
│   with module.eks_us-east-1.module.eks["01"].aws_iam_role.this[0],
│   on .terraform/modules/eks_us-east-1.eks/main.tf line 289, in resource "aws_iam_role" "this":
│  289:   name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}${var.prefix_separator}" : null
│ 
╵
```
This is fixed by setting iam_role_use_name_prefix = false in eks/modules/shared_eks/main.tf. It seems that the aws/eks module by default will use the iam_role_name as a prefix and add something else. Setting to false tells the module to create the iam role name as is.

> **TIP** There is an input override for this called cluster_name_prefix_iam_role_name that can be added to your cluster eks.tfvars config
> cluster_name_prefix_iam_role_name set to true is not needed as true is the default for the module input iam_role_use_name_prefix.
> If your env name is > 3 char, you should set **cluster_name_prefix_iam_role_name = false** in the cluster config in eks.tfvars

So the end result is we fully control the iam role name. Otherwise, the module will auto append -cluster-RANDOMCLUSTERID
```
This iam_role_name would get created as this if we do NOT set cluster_name_prefix_iam_role_name = false

owner-hello-dev-A-use1-cluster-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

This iam_role_name would get created as this if we do set cluster_name_prefix_iam_role_name = false

owner-hello-dev-A-use1
```

### Node groups take forever to update version
[1619](https://github.com/aws/containers-roadmap/issues/1619)
[REF](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-update-behavior.html)

