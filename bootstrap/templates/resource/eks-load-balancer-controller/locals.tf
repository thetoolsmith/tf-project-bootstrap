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

  tags = merge(tomap(var.required_tags), tomap(var.optional_tags))

}
