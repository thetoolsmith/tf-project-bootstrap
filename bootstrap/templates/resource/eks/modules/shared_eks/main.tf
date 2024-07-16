##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.2
##################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


data "aws_region" "current" {}

module "eks" {
  for_each = var.cluster

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                    = join("-", [var.unique_name, each.key, local.short_region[data.aws_region.current.name]])
  cluster_version                 = each.value.version
  cluster_endpoint_public_access  = (each.value.enable_public_access == null) ? false : each.value.enable_public_access
  cluster_endpoint_private_access = (each.value.enable_private_access == null) ? true : each.value.enable_private_access
  vpc_id                          = each.value.vpc_id[data.aws_region.current.name]
  subnet_ids                      = each.value.subnet_ids[data.aws_region.current.name]
  control_plane_subnet_ids        = each.value.subnet_ids[data.aws_region.current.name]
  aws_auth_roles                  = (each.value.auth_roles != null) ? each.value.auth_roles : []
  aws_auth_users                  = (each.value.auth_users != null) ? each.value.auth_users : []
  aws_auth_accounts               = (each.value.auth_accounts != null) ? each.value.auth_accounts : []
  kms_key_administrators          = (each.value.kms_key_administrators != null) ? each.value.kms_key_administrators : []
  cluster_addons                  = (each.value.cluster_addons != null) ? merge(each.value.cluster_addons, local.cluster_addons_changes[each.key]) : {}

  iam_role_use_name_prefix = (each.value.cluster_name_prefix_iam_role_name != null) ? each.value.cluster_name_prefix_iam_role_name : true


  /* The eks.tfvars has 3 possible inputs that would trigger a need to set config_map, but we only have one variable input to the aws/eks module.
     Therefore, we only check that the inputs are being set. We cannot also check the length of the variable list as well since there are 3 inputs
     each with a possible different setting. I.E. not set, empty, has values.
     The aws/eks module would have been better to keep all three separate inputs and handle the evaluation to determine if it needs to create
     and/or manage the config map.
  */

  create_aws_auth_configmap = (each.value.auth_roles != null || each.value.auth_users != null || each.value.auth_accounts != null) ? true : false
  manage_aws_auth_configmap = (each.value.auth_roles != null || each.value.auth_users != null || each.value.auth_accounts != null) ? true : false


  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    instance_types             = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    for k, v in each.value.eks_managed_node_groups :
    k => {
      use_custom_launch_template = v.use_custom_launch_template
      disk_size                  = v.disk_size
      remote_access = {
        ec2_ssh_key               = (v.ssh_keyname != null) ? v.ssh_keyname : module.key_pair[each.key].key_pair_name
        source_security_group_ids = (v.source_security_group_ids != []) ? v.source_security_group_ids : [aws_security_group.remote_access[each.key].id]
      }
    }
  }

  tags                           = var.tags
  cluster_encryption_policy_tags = var.tags
  cluster_security_group_tags    = var.tags
  cluster_tags                   = var.tags
  node_security_group_tags       = var.tags
  iam_role_tags                  = var.tags

}

resource "aws_security_group" "remote_access" {
  for_each = var.cluster

  name_prefix = join("-", [var.unique_name, each.key, local.short_region[data.aws_region.current.name], "remote-access"])
  description = "Allow remote SSH access"
  vpc_id      = each.value.vpc_id[data.aws_region.current.name]

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = join("-", [var.unique_name, "remote"]) })
}

module "key_pair" {
  for_each = var.cluster

  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = join("-", [var.unique_name, each.key, local.short_region[data.aws_region.current.name]])
  create_private_key = true

  tags = var.tags
}

/* SEE README FOR ERROR THROWN WHEN REMOVING A CLUSTER FROM CONFIG
resource "local_file" "kubeconfig" {
  for_each = module.eks

  content  = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: each.value.endpoint
    certificate-authority-data: each.value.certificate_authority.0.data
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - each.value.cluster_name
KUBECONFIG

  filename = "~/.kube/config"
}
*/

