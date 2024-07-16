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

output "oidc_data" {
  value = (local.eks_use1 != null) ? data.aws_iam_openid_connect_provider.use1 : ((local.eks_usw2 != null) ? data.aws_iam_openid_connect_provider.usw2 : ((local.eks_use2 != null) ? data.aws_iam_openid_connect_provider.use2 : ((local.eks_usw1 != null) ? data.aws_iam_openid_connect_provider.usw1 : null)))
}

output "kubernetes_application_attributes" {
  value = module.eks-load-balancer-controller-use1[*].kubernetes_application_attributes
}

output "iam_role_attributes" {
  value = merge(
    { for i in module.eks-load-balancer-controller-use1 : "us-east-1" => i.iam_role_attributes },
    { for i in module.eks-load-balancer-controller-use2 : "us-east-2" => i.iam_role_attributes },
    { for i in module.eks-load-balancer-controller-usw1 : "us-west-1" => i.iam_role_attributes },
    { for i in module.eks-load-balancer-controller-usw2 : "us-west-2" => i.iam_role_attributes }
  )
}

output "helm_release_application" {
  value = flatten([
    module.eks-load-balancer-controller-use1[*].helm_release_application_metadata,
    module.eks-load-balancer-controller-use2[*].helm_release_application_metadata,
    module.eks-load-balancer-controller-usw1[*].helm_release_application_metadata,
    module.eks-load-balancer-controller-usw2[*].helm_release_application_metadata
  ])
}

output "helm_release" {
  value = flatten([
    module.eks-load-balancer-controller-use1[*].helm_release_metadata,
    module.eks-load-balancer-controller-use1[*].helm_release_metadata,
    module.eks-load-balancer-controller-use1[*].helm_release_metadata,
    module.eks-load-balancer-controller-use1[*].helm_release_metadata
  ])
}
