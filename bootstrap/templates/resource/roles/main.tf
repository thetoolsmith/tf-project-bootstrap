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

data "aws_caller_identity" "current" {}

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
