##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

locals {
  owner              = element(split("-", var.cluster_name), 0)
  environment        = element(split("-", var.cluster_name), 2)
  product            = element(split("-", var.cluster_name), 1)
  cluster_region     = element(split("-", var.cluster_name), 4)
  cluster_short_name = element(split("-", var.cluster_name), 3)

  eks_use1 = (local.cluster_region == "use1") ? var.cluster_name : null
  eks_use2 = (local.cluster_region == "use2") ? var.cluster_name : null
  eks_usw1 = (local.cluster_region == "usw1") ? var.cluster_name : null
  eks_usw2 = (local.cluster_region == "usw2") ? var.cluster_name : null

  have_clusters = (
    (local.eks_use1 != null) ||
    (local.eks_use2 != null) ||
    (local.eks_usw1 != null) ||
  (local.eks_usw2 != null)) ? true : false

  cluster_oidc_url = (local.eks_use1 != null) ? data.aws_eks_cluster.use1[0].identity.0.oidc.0.issuer : ((local.eks_use2 != null) ? data.aws_eks_cluster.use2[0].identity.0.oidc.0.issuer : ((local.eks_usw1 != null) ? data.aws_eks_cluster.usw1[0].identity.0.oidc.0.issuer : ((local.eks_usw2 != null) ? data.aws_eks_cluster.usw2[0].identity.0.oidc.0.issuer : null)))

  cluster_oidc_arn = (local.eks_use1 != null) ? data.aws_iam_openid_connect_provider.use1[0].arn : ((local.eks_use2 != null) ? data.aws_iam_openid_connect_provider.use2[0].arn : ((local.eks_usw1 != null) ? data.aws_iam_openid_connect_provider.usw1[0].arn : ((local.eks_usw2 != null) ? data.aws_iam_openid_connect_provider.usw2[0].arn : null)))

  cluster_oidc_provider = substr(local.cluster_oidc_url, 8, -1)

  tags = merge(tomap(var.required_tags), tomap(var.optional_tags))

  // for testing, remove when done
  acm_pca_arn = {
    __CA_1__ = "arn:aws:acm-pca:us-east-1:__IAM_ACCOUNT__:certificate-authority/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    __CA_2__ = "arn:aws:acm-pca:us-east-1:__IAM_ACCOUNT__:certificate-authority/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    __CA_3__ = "arn:aws:acm-pca:us-east-1:__IAM_ACCOUNT__:certificate-authority/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }

}
