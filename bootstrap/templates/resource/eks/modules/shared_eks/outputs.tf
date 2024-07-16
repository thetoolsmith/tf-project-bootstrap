##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

//output "kubeconfig" {
//  value = "${module.kubeconfig.*}"
//}

//output "kubeconfigs" {
//  value = {
//    for k, v in module.kubeconfig :
//    k => v
//  }
//}


output "cluster_roles" {
  value = local.cluster_roles
}

//output "cluster_roles_resource_overrides" {
//  value = {
//    for c in var.cluster : "roles" => c.roles_resource_overrides if contains(keys(c), "roles_resource_overrides")
//  }
//}


output "cluster_name" {
  value = {
    for instance in module.eks :
    instance.cluster_name => instance.cluster_name
  }
}

output "cluster_id" {
  value = {
    for instance in module.eks :
    instance.cluster_name => instance.cluster_id
  }
}

output "cluster_status" {
  value = {
    for instance in module.eks :
    instance.cluster_name => instance.cluster_status
  }
}

output "cluster_arn" {
  value = {
    for instance in module.eks :
    instance.cluster_name => instance.cluster_arn
  }
}

output "cluster_endpoint" {
  value = {
    for instance in module.eks :
    instance.cluster_name => instance.cluster_endpoint
  }
}

output "cluster_identity_providers" {
  value = {
    for instance in module.eks :
    instance.cluster_name => instance.cluster_identity_providers
  }
}

output "cluster_oidc_provider_arn" {
  value = {
    for instance in module.eks :
    instance.cluster_name => instance.oidc_provider_arn
  }
}

output "cluster_oidc_provider" {
  value = {
    for instance in module.eks :
    instance.cluster_name => instance.oidc_provider
  }
}

output "cluster_oidc_url" {
  value = {
    for instance in module.eks :
    instance.cluster_name => instance.cluster_oidc_issuer_url
  }
}

// COLLECTION OUTPUTS
output "cluster_iam_role" {
  value = {
    for instance in module.eks :
    instance.cluster_name => merge(
      { role_arn = instance.cluster_iam_role_arn },
      { role_name = instance.cluster_iam_role_name },
    { role_unique_id = instance.cluster_iam_role_unique_id })
  }
}

output "cluster_node_groups" {
  value = {
    for instance in module.eks :
    instance.cluster_name => merge(
      { for k, v in instance.self_managed_node_groups : join("_", ["self", k]) => v if v != null },
    { for k, v in instance.eks_managed_node_groups : join("_", ["eks", k]) => v if v != null })
  }
}

output "cluster_security" {
  value = {
    for instance in module.eks :
    instance.cluster_name => merge(
      { oidc_url = instance.cluster_oidc_issuer_url },
      { oidc_provider = instance.oidc_provider },
      { oidc_provider_arn = instance.oidc_provider_arn },
      { primary_secgrp_id = instance.cluster_primary_security_group_id },
      { secgrp_arn = instance.cluster_security_group_arn },
      { secgrp_id = instance.cluster_security_group_id },
      { kms_key_arn = instance.kms_key_arn },
      { kms_key_id = instance.kms_key_id },
    { ca_cert = instance.cluster_certificate_authority_data })
  }
}

//for debugging
output "cluster_data" {
  value = {
    for instance in module.eks :
    instance.cluster_name => { for k, v in instance : k => v }
  }
}
