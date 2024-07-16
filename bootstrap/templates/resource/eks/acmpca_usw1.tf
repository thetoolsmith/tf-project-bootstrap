##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

data "tls_certificate" "usw1-eks-cluster" {
  for_each = { for k, v in module.eks_us-west-1.cluster_oidc_url : k => v }
  url      = each.value
}
resource "aws_iam_openid_connect_provider" "usw1-acmpca-identity" {
  for_each = { for k, v in module.eks_us-west-1.cluster_oidc_url : k => v }

  provider = aws.acmpca

  url = each.value

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [data.tls_certificate.usw1-eks-cluster[each.key].certificates[0].sha1_fingerprint]

  tags = merge(local.tags, {
    "cluster_name" = each.key
  })
}

data "aws_iam_policy_document" "usw1-acmpca-assume-role" {
  for_each = { for k, v in module.eks_us-west-1.cluster_oidc_provider : k => v }

  provider = aws.acmpca

  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.usw1-acmpca-identity[each.key].arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringLike"
      variable = join(":", [each.value, "sub"])
      values   = ["system:serviceaccount:cert-manager:aws-privateca-issuer"]
    }
  }
}

resource "aws_iam_role" "usw1-acmpca-role" {
  for_each = { for k, v in module.eks_us-west-1.cluster_oidc_provider_arn : k => v }

  provider = aws.acmpca

  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.usw1-acmpca-assume-role[each.key].json
  tags               = local.tags
}

data "aws_iam_policy_document" "usw1-acmpca-policy" {
  for_each = { for k, v in module.eks_us-west-1.cluster_arn : k => v }

  provider = aws.acmpca

  statement {
    effect = "Allow"
    actions = [
      "acm-pca:DescribeCertificateAuthority",
      "acm-pca:GetCertificate",
      "acm-pca:IssueCertificate"
    ]
    sid       = "awspca"
    resources = [local.acm_pca_arn[data.aws_caller_identity.current.account_id]]
  }
}

resource "aws_iam_policy" "usw1-acmpca-policy" {
  for_each = { for k, v in module.eks_us-west-1.cluster_arn : k => v }

  provider = aws.acmpca

  name        = each.key
  description = "eks identity policy"
  policy      = data.aws_iam_policy_document.usw1-acmpca-policy[each.key].json

  tags = merge(local.tags, {
    "cluster_name" = each.key
  })
}

resource "aws_iam_role_policy_attachment" "usw1-attach" {
  for_each = { for k, v in module.eks_us-west-1.cluster_arn : k => v }

  provider = aws.acmpca

  role       = aws_iam_role.usw1-acmpca-role[each.key].name
  policy_arn = aws_iam_policy.usw1-acmpca-policy[each.key].arn
}
