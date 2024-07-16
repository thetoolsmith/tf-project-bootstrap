##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################
output "cluster_name" {
  value = var.cluster_name
}

output "cluster_data" {
  value = (local.eks_use1 != null) ? data.aws_eks_cluster.use1 : ((local.eks_usw2 != null) ? data.aws_eks_cluster.usw2 : ((local.eks_use2 != null) ? data.aws_eks_cluster.use2 : ((local.eks_usw1 != null) ? data.aws_eks_cluster.usw1 : null)))
}

output "cluster_oidc_url" {
  value = local.cluster_oidc_url
}

output "cluster_oidc_arn" {
  value = local.cluster_oidc_arn
}

output "cluster_oidc_provider" {
  value = local.cluster_oidc_provider
}
