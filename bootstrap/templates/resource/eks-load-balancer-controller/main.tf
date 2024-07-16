##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_eks_cluster" "use1" {
  count = (local.eks_use1 != null) ? 1 : 0

  provider = aws.use1

  name = var.cluster_name
}

data "aws_eks_cluster" "usw2" {
  count = (local.eks_usw2 != null) ? 1 : 0

  provider = aws.usw2

  name = var.cluster_name
}

data "aws_eks_cluster" "use2" {
  count = (local.eks_use2 != null) ? 1 : 0

  provider = aws.use2

  name = var.cluster_name
}

data "aws_eks_cluster" "usw1" {
  count = (local.eks_usw1 != null) ? 1 : 0

  provider = aws.usw1

  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "use1" {
  count = (local.eks_use1 != null) ? 1 : 0

  provider = aws.use1

  url = data.aws_eks_cluster.use1[count.index].identity.0.oidc.0.issuer
}

data "aws_iam_openid_connect_provider" "usw2" {
  count = (local.eks_usw2 != null) ? 1 : 0

  provider = aws.usw2

  url = data.aws_eks_cluster.usw2[count.index].identity.0.oidc.0.issuer
}

data "aws_iam_openid_connect_provider" "use2" {
  count = (local.eks_use2 != null) ? 1 : 0

  provider = aws.use2

  url = data.aws_eks_cluster.use2[count.index].identity.0.oidc.0.issuer
}

data "aws_iam_openid_connect_provider" "usw1" {
  count = (local.eks_usw1 != null) ? 1 : 0

  provider = aws.usw1

  url = data.aws_eks_cluster.usw1[count.index].identity.0.oidc.0.issuer
}

module "eks-load-balancer-controller-use1" {
  count = (local.eks_use1 != null) ? 1 : 0

  source  = "lablabs/eks-load-balancer-controller/aws"
  version = "1.2.0"

  providers = {
    aws = aws.use1
  }

  cluster_identity_oidc_issuer     = data.aws_iam_openid_connect_provider.use1[count.index].url
  cluster_identity_oidc_issuer_arn = data.aws_iam_openid_connect_provider.use1[count.index].arn
  cluster_name                     = var.cluster_name
  helm_release_name                = "aws-lbc"
  service_account_name             = "aws-lbc"
  namespace                        = "aws-lb-controller"
  irsa_role_name_prefix            = lower(var.cluster_name)
  irsa_tags                        = local.tags
}

module "eks-load-balancer-controller-use2" {
  count = (local.eks_use2 != null) ? 1 : 0

  source  = "lablabs/eks-load-balancer-controller/aws"
  version = "1.2.0"

  providers = {
    aws = aws.use2
  }

  cluster_identity_oidc_issuer     = data.aws_iam_openid_connect_provider.use2[count.index].url
  cluster_identity_oidc_issuer_arn = data.aws_iam_openid_connect_provider.use2[count.index].arn
  cluster_name                     = var.cluster_name
  helm_release_name                = "aws-lbc"
  service_account_name             = "aws-lbc"
  namespace                        = "aws-lb-controller"
  irsa_role_name_prefix            = lower(var.cluster_name)
  irsa_tags                        = local.tags

}

module "eks-load-balancer-controller-usw2" {
  count = (local.eks_usw2 != null) ? 1 : 0

  source  = "lablabs/eks-load-balancer-controller/aws"
  version = "1.2.0"

  providers = {
    aws = aws.usw2
  }

  cluster_identity_oidc_issuer     = data.aws_iam_openid_connect_provider.usw2[count.index].url
  cluster_identity_oidc_issuer_arn = data.aws_iam_openid_connect_provider.usw2[count.index].arn
  cluster_name                     = var.cluster_name
  helm_release_name                = "aws-lbc"
  service_account_name             = "aws-lbc"
  namespace                        = "aws-lb-controller"
  irsa_role_name_prefix            = lower(var.cluster_name)
  irsa_tags                        = local.tags

}

module "eks-load-balancer-controller-usw1" {
  count = (local.eks_usw1 != null) ? 1 : 0

  source  = "lablabs/eks-load-balancer-controller/aws"
  version = "1.2.0"

  providers = {
    aws = aws.usw1
  }

  cluster_identity_oidc_issuer     = data.aws_iam_openid_connect_provider.usw1[count.index].url
  cluster_identity_oidc_issuer_arn = data.aws_iam_openid_connect_provider.usw1[count.index].arn
  cluster_name                     = var.cluster_name
  helm_release_name                = "aws-lbc"
  service_account_name             = "aws-lbc"
  namespace                        = "aws-lb-controller"
  irsa_role_name_prefix            = lower(var.cluster_name)
  irsa_tags                        = local.tags

}

resource "aws_secretsmanager_secret" "lb-controller-iam_attributes-use1" {
  count = (local.eks_use1 != null) ? 1 : 0

  description             = "aws-load-balancer-controller iam role attributes"
  name                    = join("/", [local.owner, local.product, local.environment, var.cluster_name, "iam-attributes"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "lb-controller-iam_attributes-use1-version" {
  count = (local.eks_use1 != null) ? 1 : 0

  secret_id = aws_secretsmanager_secret.lb-controller-iam_attributes-use1[count.index].name
  secret_string = jsonencode(
    {
      arn                 = module.eks-load-balancer-controller-use1[count.index].iam_role_attributes.arn
      unique_id           = module.eks-load-balancer-controller-use1[count.index].iam_role_attributes.unique_id
      managed_policy_arns = module.eks-load-balancer-controller-use1[count.index].iam_role_attributes.managed_policy_arns
      assume_role_policy  = module.eks-load-balancer-controller-use1[count.index].iam_role_attributes.assume_role_policy
    }
  )
}

resource "aws_secretsmanager_secret" "lb-controller-iam_attributes-use2" {
  count = (local.eks_use2 != null) ? 1 : 0

  description             = "aws-load-balancer-controller iam role attributes"
  name                    = join("/", [local.owner, local.product, local.environment, var.cluster_name, "iam-attributes"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "lb-controller-iam_attributes-use2-version" {
  count = (local.eks_use2 != null) ? 1 : 0

  secret_id = aws_secretsmanager_secret.lb-controller-iam_attributes-use2[count.index].name
  secret_string = jsonencode(
    {
      arn                 = module.eks-load-balancer-controller-use2[count.index].iam_role_attributes.arn
      unique_id           = module.eks-load-balancer-controller-use2[count.index].iam_role_attributes.unique_id
      managed_policy_arns = module.eks-load-balancer-controller-use2[count.index].iam_role_attributes.managed_policy_arns
      assume_role_policy  = module.eks-load-balancer-controller-use2[count.index].iam_role_attributes.assume_role_policy
    }
  )
}

resource "aws_secretsmanager_secret" "lb-controller-iam_attributes-usw1" {
  count = (local.eks_usw1 != null) ? 1 : 0

  description             = "aws-load-balancer-controller iam role attributes"
  name                    = join("/", [local.owner, local.product, local.environment, var.cluster_name, "iam-attributes"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "lb-controller-iam_attributes-usw1-version" {
  count = (local.eks_usw1 != null) ? 1 : 0

  secret_id = aws_secretsmanager_secret.lb-controller-iam_attributes-usw1[count.index].name
  secret_string = jsonencode(
    {
      arn                 = module.eks-load-balancer-controller-usw1[count.index].iam_role_attributes.arn
      unique_id           = module.eks-load-balancer-controller-usw1[count.index].iam_role_attributes.unique_id
      managed_policy_arns = module.eks-load-balancer-controller-usw1[count.index].iam_role_attributes.managed_policy_arns
      assume_role_policy  = module.eks-load-balancer-controller-usw1[count.index].iam_role_attributes.assume_role_policy
    }
  )
}

resource "aws_secretsmanager_secret" "lb-controller-iam_attributes-usw2" {
  count = (local.eks_usw2 != null) ? 1 : 0

  description             = "aws-load-balancer-controller iam role attributes"
  name                    = join("/", [local.owner, local.product, local.environment, var.cluster_name, "iam-attributes"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "lb-controller-iam_attributes-usw2-version" {
  count = (local.eks_usw2 != null) ? 1 : 0

  // another method
  // for_each = { for k, v in module.eks-load-balancer-controller-usw2 : k => v }

  secret_id = aws_secretsmanager_secret.lb-controller-iam_attributes-usw2[count.index].name
  secret_string = jsonencode(
    {
      arn                 = module.eks-load-balancer-controller-usw2[count.index].iam_role_attributes.arn
      unique_id           = module.eks-load-balancer-controller-usw2[count.index].iam_role_attributes.unique_id
      managed_policy_arns = module.eks-load-balancer-controller-usw2[count.index].iam_role_attributes.managed_policy_arns
      assume_role_policy  = module.eks-load-balancer-controller-usw2[count.index].iam_role_attributes.assume_role_policy
    }
  )
}
