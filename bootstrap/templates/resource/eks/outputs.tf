##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

//output "kubeconfig" {
//  value = yamlencode("${module.eks_us-east-1.kubeconfig}")
//  sensitive = true
//}

output "cluster_names_string" {
  value = join(" ", flatten([
    keys(module.eks_us-east-1.cluster_arn),
    keys(module.eks_us-east-2.cluster_arn),
    keys(module.eks_us-west-1.cluster_arn),
    keys(module.eks_us-west-2.cluster_arn)
  ]))
}

output "cluster_names" {
  value = flatten([
    keys(module.eks_us-east-1.cluster_arn),
    keys(module.eks_us-east-2.cluster_arn),
    keys(module.eks_us-west-1.cluster_arn),
    keys(module.eks_us-west-2.cluster_arn)
  ])
}

//output "cluster_roles" {
//  value = module.eks_us-east-1.cluster_roles.roles_resource_overrides
//}


output "cluster_status" {
  value = merge(
    (module.eks_us-east-1.cluster_status != null) ? module.eks_us-east-1.cluster_status : {},
    (module.eks_us-east-2.cluster_status != null) ? module.eks_us-east-2.cluster_status : {},
    (module.eks_us-west-1.cluster_status != null) ? module.eks_us-west-1.cluster_status : {},
    (module.eks_us-west-2.cluster_status != null) ? module.eks_us-west-2.cluster_status : {}
  )
}

output "cluster_id" {
  value = merge(
    (module.eks_us-east-1.cluster_id != null) ? module.eks_us-east-1.cluster_id : {},
    (module.eks_us-east-2.cluster_id != null) ? module.eks_us-east-2.cluster_id : {},
    (module.eks_us-west-1.cluster_id != null) ? module.eks_us-west-1.cluster_id : {},
    (module.eks_us-west-2.cluster_id != null) ? module.eks_us-west-2.cluster_id : {}
  )
}

output "cluster_oidc_provider" {
  value = merge(
    (module.eks_us-east-1.cluster_oidc_provider != null) ? module.eks_us-east-1.cluster_oidc_provider : {},
    (module.eks_us-east-2.cluster_oidc_provider != null) ? module.eks_us-east-2.cluster_oidc_provider : {},
    (module.eks_us-west-1.cluster_oidc_provider != null) ? module.eks_us-west-1.cluster_oidc_provider : {},
    (module.eks_us-west-2.cluster_oidc_provider != null) ? module.eks_us-west-2.cluster_oidc_provider : {}
  )
}

output "cluster_oidc_provider_arn" {
  value = merge(
    (module.eks_us-east-1.cluster_oidc_provider_arn != null) ? module.eks_us-east-1.cluster_oidc_provider_arn : {},
    (module.eks_us-east-2.cluster_oidc_provider_arn != null) ? module.eks_us-east-2.cluster_oidc_provider_arn : {},
    (module.eks_us-west-1.cluster_oidc_provider_arn != null) ? module.eks_us-west-1.cluster_oidc_provider_arn : {},
    (module.eks_us-west-2.cluster_oidc_provider_arn != null) ? module.eks_us-west-2.cluster_oidc_provider_arn : {}
  )
}

output "cluster_oidc_url" {
  value = merge(
    (module.eks_us-east-1.cluster_oidc_url != null) ? module.eks_us-east-1.cluster_oidc_url : {},
    (module.eks_us-east-2.cluster_oidc_url != null) ? module.eks_us-east-2.cluster_oidc_url : {},
    (module.eks_us-west-1.cluster_oidc_url != null) ? module.eks_us-west-1.cluster_oidc_url : {},
    (module.eks_us-west-2.cluster_oidc_url != null) ? module.eks_us-west-2.cluster_oidc_url : {}
  )
}

output "cluster_arn" {
  value = merge(
    (module.eks_us-east-1.cluster_arn != null) ? module.eks_us-east-1.cluster_arn : {},
    (module.eks_us-east-2.cluster_arn != null) ? module.eks_us-east-2.cluster_arn : {},
    (module.eks_us-west-1.cluster_arn != null) ? module.eks_us-west-1.cluster_arn : {},
    (module.eks_us-west-2.cluster_arn != null) ? module.eks_us-west-2.cluster_arn : {}
  )
}

output "cluster_endpoint" {
  value = merge(
    (module.eks_us-east-1.cluster_endpoint != null) ? module.eks_us-east-1.cluster_endpoint : {},
    (module.eks_us-east-2.cluster_endpoint != null) ? module.eks_us-east-2.cluster_endpoint : {},
    (module.eks_us-west-1.cluster_endpoint != null) ? module.eks_us-west-1.cluster_endpoint : {},
    (module.eks_us-west-2.cluster_endpoint != null) ? module.eks_us-west-2.cluster_endpoint : {}
  )
}

output "cluster_identity_providers" {
  value = merge(
    (module.eks_us-east-1.cluster_identity_providers != null) ? module.eks_us-east-1.cluster_identity_providers : {},
    (module.eks_us-east-2.cluster_identity_providers != null) ? module.eks_us-east-2.cluster_identity_providers : {},
    (module.eks_us-west-1.cluster_identity_providers != null) ? module.eks_us-west-1.cluster_identity_providers : {},
    (module.eks_us-west-2.cluster_identity_providers != null) ? module.eks_us-west-2.cluster_identity_providers : {}
  )
}

output "cluster_iam_role" {
  value = merge(
    (module.eks_us-east-1.cluster_iam_role != null) ? module.eks_us-east-1.cluster_iam_role : {},
    (module.eks_us-east-2.cluster_iam_role != null) ? module.eks_us-east-2.cluster_iam_role : {},
    (module.eks_us-west-1.cluster_iam_role != null) ? module.eks_us-west-1.cluster_iam_role : {},
    (module.eks_us-west-2.cluster_iam_role != null) ? module.eks_us-west-2.cluster_iam_role : {}
  )
}

output "cluster_node_groups_use1" {
  value = { for k, v in module.eks_us-east-1.cluster_node_groups : k => v }
}
output "cluster_node_groups_use2" {
  value = { for k, v in module.eks_us-east-2.cluster_node_groups : k => v }
}
output "cluster_node_groups_usw1" {
  value = { for k, v in module.eks_us-west-1.cluster_node_groups : k => v }
}
output "cluster_node_groups_usw2" {
  value = { for k, v in module.eks_us-west-2.cluster_node_groups : k => v }
}

output "cluster_node_groups" {
  value = merge(
    { for k, v in module.eks_us-east-1.cluster_node_groups : k => v },
    { for k, v in module.eks_us-east-2.cluster_node_groups : k => v },
    { for k, v in module.eks_us-west-1.cluster_node_groups : k => v },
    { for k, v in module.eks_us-west-2.cluster_node_groups : k => v }
  )
}

output "cluster_security" {
  value = merge(
    (module.eks_us-east-1.cluster_security != null) ? module.eks_us-east-1.cluster_security : {},
    (module.eks_us-east-2.cluster_security != null) ? module.eks_us-east-2.cluster_security : {},
    (module.eks_us-west-1.cluster_security != null) ? module.eks_us-west-1.cluster_security : {},
    (module.eks_us-west-2.cluster_security != null) ? module.eks_us-west-2.cluster_security : {}
  )
}

output "acmpca-identity-provider-arn" {
  description = "Outputs a map CLUSTER_NAME = SECONDARY_IDENTITY_PROVIDER_ARN"

  value = merge(
    { for id in aws_iam_openid_connect_provider.use1-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) },
    { for id in aws_iam_openid_connect_provider.use2-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) },
    { for id in aws_iam_openid_connect_provider.usw1-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) },
    { for id in aws_iam_openid_connect_provider.usw2-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) }
  )
}

output "acmpca-policy-arn" {
  description = "Outputs a map CLUSTER_NAME = SECONDARY_POLICY_ARN"

  value = merge(
    { for policy in aws_iam_policy.use1-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) },
    { for policy in aws_iam_policy.use2-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) },
    { for policy in aws_iam_policy.usw1-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) },
    { for policy in aws_iam_policy.usw2-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) }
  )
}

output "acmpca-role-info" {
  description = "Outputs all acmpca account role useful data for all clusters in all regions"
  value = merge(
    (aws_iam_role.use1-acmpca-role != null) ? { for i in aws_iam_role.use1-acmpca-role : i.name => { arn = i.arn, unique_id = i.unique_id } } : {},
    (aws_iam_role.use2-acmpca-role != null) ? { for i in aws_iam_role.use2-acmpca-role : i.name => { arn = i.arn, unique_id = i.unique_id } } : {},
    (aws_iam_role.usw1-acmpca-role != null) ? { for i in aws_iam_role.usw1-acmpca-role : i.name => { arn = i.arn, unique_id = i.unique_id } } : {},
    (aws_iam_role.usw2-acmpca-role != null) ? { for i in aws_iam_role.usw2-acmpca-role : i.name => { arn = i.arn, unique_id = i.unique_id } } : {}
  )
}

output "acmpca-role-arn" {
  description = "Outputs a map object of CLUSTER_NAME: SECONDARY_ROLE_ARN for all clusters in all regions"
  value = merge(
    (aws_iam_role.use1-acmpca-role != null) ? { for i in aws_iam_role.use1-acmpca-role : i.name => i.arn } : {},
    (aws_iam_role.use2-acmpca-role != null) ? { for i in aws_iam_role.use2-acmpca-role : i.name => i.arn } : {},
    (aws_iam_role.usw1-acmpca-role != null) ? { for i in aws_iam_role.usw1-acmpca-role : i.name => i.arn } : {},
    (aws_iam_role.usw2-acmpca-role != null) ? { for i in aws_iam_role.usw2-acmpca-role : i.name => i.arn } : {}
  )
}

output "acmpca-role-arn-map-string" {
  description = <<EOF
    This output is specially structured to be parsed by shell programs.
    To avoid OS conflicts in how shell arrays are handled, we simply build a string of CLUSTER_NAME::ROLE_ARN.
  EOF

  value = join(" ", flatten([
    [for i in aws_iam_role.use1-acmpca-role : join("::", [i.name, i.arn])],
    [for i in aws_iam_role.use2-acmpca-role : join("::", [i.name, i.arn])],
    [for i in aws_iam_role.usw1-acmpca-role : join("::", [i.name, i.arn])],
    [for i in aws_iam_role.usw2-acmpca-role : join("::", [i.name, i.arn])]
  ]))
}

output "acmpca-role-unique_id" {
  value = merge(
    (aws_iam_role.use1-acmpca-role != null) ? { for i in aws_iam_role.use1-acmpca-role : i.name => i.unique_id } : {},
    (aws_iam_role.use2-acmpca-role != null) ? { for i in aws_iam_role.use2-acmpca-role : i.name => i.unique_id } : {},
    (aws_iam_role.usw1-acmpca-role != null) ? { for i in aws_iam_role.usw1-acmpca-role : i.name => i.unique_id } : {},
    (aws_iam_role.usw2-acmpca-role != null) ? { for i in aws_iam_role.usw2-acmpca-role : i.name => i.unique_id } : {}
  )
}

//for debugging
//output "cluster_data" {
//  value = merge(
//    (module.eks_us-east-1.cluster_data != null) ? module.eks_us-east-1.cluster_data : {},
//    (module.eks_us-east-2.cluster_data != null) ? module.eks_us-east-2.cluster_data : {},
//    (module.eks_us-west-1.cluster_data != null) ? module.eks_us-west-1.cluster_data : {},
//    (module.eks_us-west-2.cluster_data != null) ? module.eks_us-west-2.cluster_data : {}
//  )
//}
