##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

terraform {
  backend "s3" {}
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "eks_us-east-1" {
  source = "./modules/shared_eks"

  providers = {
    aws = aws.use1
  }

  cluster     = local.eks_use1
  roles       = var.roles
  product     = local.product
  unique_name = local.unique_name
  environment = local.environment
  tags        = local.tags
}

module "eks_us-east-2" {
  source = "./modules/shared_eks"

  providers = {
    aws = aws.use2
  }

  cluster     = local.eks_use2
  roles       = var.roles
  product     = local.product
  unique_name = local.unique_name
  environment = local.environment
  tags        = local.tags
}

module "eks_us-west-1" {
  source = "./modules/shared_eks"

  providers = {
    aws = aws.usw1
  }

  cluster     = local.eks_usw1
  roles       = var.roles
  product     = local.product
  unique_name = local.unique_name
  environment = local.environment
  tags        = local.tags
}

module "eks_us-west-2" {
  source = "./modules/shared_eks"

  providers = {
    aws = aws.usw2
  }

  cluster     = local.eks_usw2
  roles       = var.roles
  product     = local.product
  unique_name = local.unique_name
  environment = local.environment
  tags        = local.tags
}


/* TEST ADD SECRET FOR ACMPCA IAM ACCOUNT */
resource "aws_secretsmanager_secret" "acmpca-iam-test" {
  for_each = { for k, v in module.eks_us-east-1.cluster_arn : k => v }

  provider = aws.acmpca

  description             = "testing tf provider account switch"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "foobar"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "acmpca-test" {
  for_each = { for k, v in module.eks_us-east-1.cluster_arn : k => v }

  provider = aws.acmpca

  secret_id     = aws_secretsmanager_secret.acmpca-test[each.key].name
  secret_string = join("-", [each.key, "bababababababa"])
}
/* END TEST */



// SINGLE VALUE SECRETS
resource "aws_secretsmanager_secret" "use1-cluster-arn" {
  for_each = { for k, v in module.eks_us-east-1.cluster_arn : k => v }

  description             = "region and cluster specific arn"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "cluster_arn"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "use1-cluster-arn-version" {
  for_each = { for k, v in module.eks_us-east-1.cluster_arn : k => v }

  secret_id     = aws_secretsmanager_secret.use1-cluster-arn[each.key].name
  secret_string = jsonencode(module.eks_us-east-1.cluster_arn[each.key])
}

resource "aws_secretsmanager_secret" "cluster-external-secrets" {
  for_each = merge(
    (module.eks_us-east-1.cluster_arn != null) ? module.eks_us-east-1.cluster_arn : {},
    (module.eks_us-east-2.cluster_arn != null) ? module.eks_us-east-2.cluster_arn : {},
    (module.eks_us-west-1.cluster_arn != null) ? module.eks_us-west-1.cluster_arn : {},
    (module.eks_us-west-2.cluster_arn != null) ? module.eks_us-west-2.cluster_arn : {}
  )

  description             = "cluster external-secrets path"
  name                    = join("/", ["external-secrets", each.key, "cluster_arn"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "cluster-external-secrets-version" {
  for_each = merge(
    (module.eks_us-east-1.cluster_arn != null) ? module.eks_us-east-1.cluster_arn : {},
    (module.eks_us-east-2.cluster_arn != null) ? module.eks_us-east-2.cluster_arn : {},
    (module.eks_us-west-1.cluster_arn != null) ? module.eks_us-west-1.cluster_arn : {},
    (module.eks_us-west-2.cluster_arn != null) ? module.eks_us-west-2.cluster_arn : {}
  )

  secret_id     = aws_secretsmanager_secret.cluster-external-secrets[each.key].name
  secret_string = jsonencode(each.value)
}


// MULTI-VALUE (COLLECTION) SECRETS
resource "aws_secretsmanager_secret" "use1-cluster-info" {
  for_each = { for k, v in module.eks_us-east-1.cluster_arn : k => v }

  description             = "region and cluster specific information"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "cluster_info"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "use1-cluster-info-version" {
  for_each = { for k, v in module.eks_us-east-1.cluster_arn : k => v }

  secret_id = aws_secretsmanager_secret.use1-cluster-info[each.key].name
  secret_string = jsonencode(merge(
    { arn = module.eks_us-east-1.cluster_arn[each.key] },
    { endpoint = module.eks_us-east-1.cluster_endpoint[each.key] },
    { name = each.key },
    { for k, v in module.eks_us-east-1.cluster_iam_role[each.key] : k => v },
    { for k, v in module.eks_us-east-1.cluster_security[each.key] : k => v },
    { for k, v in module.eks_us-east-1.cluster_node_groups[each.key] : k => v }
  ))
}

resource "aws_secretsmanager_secret" "use2-cluster-info" {
  for_each = { for k, v in module.eks_us-east-2.cluster_arn : k => v }

  description             = "region and cluster specific information"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "cluster_info"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "use2-cluster-info-version" {
  for_each = { for k, v in module.eks_us-east-2.cluster_arn : k => v }

  secret_id = aws_secretsmanager_secret.use2-cluster-info[each.key].name
  secret_string = jsonencode(merge(
    { arn = module.eks_us-east-2.cluster_arn[each.key] },
    { endpoint = module.eks_us-east-2.cluster_endpoint[each.key] },
    { name = each.key },
    { for k, v in module.eks_us-east-2.cluster_iam_role[each.key] : k => v },
    { for k, v in module.eks_us-east-2.cluster_security[each.key] : k => v },
    { for k, v in module.eks_us-east-2.cluster_node_groups[each.key] : k => v }
  ))
}

resource "aws_secretsmanager_secret" "usw1-cluster-info" {
  for_each = { for k, v in module.eks_us-west-1.cluster_arn : k => v }

  description             = "region and cluster specific information"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "cluster_info"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "usw1-cluster-info-version" {
  for_each = { for k, v in module.eks_us-west-1.cluster_arn : k => v }

  secret_id = aws_secretsmanager_secret.usw1-cluster-info[each.key].name
  secret_string = jsonencode(merge(
    { arn = module.eks_us-west-1.cluster_arn[each.key] },
    { endpoint = module.eks_us-west-1.cluster_endpoint[each.key] },
    { name = each.key },
    { for k, v in module.eks_us-west-1.cluster_iam_role[each.key] : k => v },
    { for k, v in module.eks_us-west-1.cluster_security[each.key] : k => v },
    { for k, v in module.eks_us-west-1.cluster_node_groups[each.key] : k => v }
  ))
}

resource "aws_secretsmanager_secret" "usw2-cluster-info" {
  for_each = { for k, v in module.eks_us-west-2.cluster_arn : k => v }

  description             = "region and cluster specific information"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "cluster_info"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "usw2-cluster-info-version" {
  for_each = { for k, v in module.eks_us-west-2.cluster_arn : k => v }

  secret_id = aws_secretsmanager_secret.usw2-cluster-info[each.key].name
  secret_string = jsonencode(merge(
    { arn = module.eks_us-west-2.cluster_arn[each.key] },
    { endpoint = module.eks_us-west-2.cluster_endpoint[each.key] },
    { name = each.key },
    { for k, v in module.eks_us-west-2.cluster_iam_role[each.key] : k => v },
    { for k, v in module.eks_us-west-2.cluster_security[each.key] : k => v },
    { for k, v in module.eks_us-west-2.cluster_node_groups[each.key] : k => v }
  ))
}

resource "aws_secretsmanager_secret" "cluster-arns" {
  description             = "all cluster all region arns"
  name                    = join("/", [replace(local.unique_name, "-", "/"), "cluster-arns"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "cluster-arns-version" {
  secret_id = aws_secretsmanager_secret.cluster-arns.name
  secret_string = jsonencode(merge(
    module.eks_us-east-1.cluster_arn,
    module.eks_us-east-2.cluster_arn,
    module.eks_us-west-1.cluster_arn,
    module.eks_us-west-2.cluster_arn)
  )
}

resource "aws_secretsmanager_secret" "use1-cluster-security" {
  for_each = { for k, v in module.eks_us-east-1.cluster_arn : k => v }

  description             = "region and cluster specific security information"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "cluster_security"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "use1-cluster-security-version" {
  for_each = { for k, v in module.eks_us-east-1.cluster_arn : k => v }

  secret_id     = aws_secretsmanager_secret.use1-cluster-security[each.key].name
  secret_string = jsonencode(merge(module.eks_us-east-1.cluster_security[each.key]))
}

resource "aws_secretsmanager_secret" "use2-cluster-security" {
  for_each = { for k, v in module.eks_us-east-2.cluster_arn : k => v }

  description             = "region and cluster specific security information"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "cluster_security"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "use2-cluster-security-version" {
  for_each = { for k, v in module.eks_us-east-2.cluster_arn : k => v }

  secret_id     = aws_secretsmanager_secret.use2-cluster-security[each.key].name
  secret_string = jsonencode(merge(module.eks_us-east-2.cluster_security[each.key]))
}

resource "aws_secretsmanager_secret" "usw1-cluster-security" {
  for_each = { for k, v in module.eks_us-west-1.cluster_arn : k => v }

  description             = "region and cluster specific security information"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "cluster_security"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "usw1-cluster-security-version" {
  for_each = { for k, v in module.eks_us-west-1.cluster_arn : k => v }

  secret_id     = aws_secretsmanager_secret.usw1-cluster-security[each.key].name
  secret_string = jsonencode(merge(module.eks_us-west-1.cluster_security[each.key]))
}

resource "aws_secretsmanager_secret" "usw2-cluster-security" {
  for_each = { for k, v in module.eks_us-west-2.cluster_arn : k => v }

  description             = "region and cluster specific security information"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "cluster_security"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "usw2-cluster-security-version" {
  for_each = { for k, v in module.eks_us-west-2.cluster_arn : k => v }

  secret_id     = aws_secretsmanager_secret.usw2-cluster-security[each.key].name
  secret_string = jsonencode(merge(module.eks_us-west-2.cluster_security[each.key]))
}

// CLUSTER SPECIFIC DATA
resource "aws_secretsmanager_secret" "cluster-data-use1" {
  for_each = { for k, v in local.eks_use1 : k => k }

  description             = "cluster specific data"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "use1", "data"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "cluster-data-version-use1" {
  for_each = { for k, v in local.eks_use1 : k => k }

  secret_id = aws_secretsmanager_secret.cluster-data-use1[each.key].name
  secret_string = jsonencode(merge(
    { (each.key) = length(module.eks_us-east-1.cluster_arn) > 0 ? {
      security = { for k, v in module.eks_us-east-1.cluster_security[join("-", [local.unique_name, each.key, "use1"])] : k => v },
      iam      = { for k, v in module.eks_us-east-1.cluster_iam_role[join("-", [local.unique_name, each.key, "use1"])] : k => v },
      arn      = module.eks_us-east-1.cluster_arn[join("-", [local.unique_name, each.key, "use1"])],
      endpoint = module.eks_us-east-1.cluster_endpoint[join("-", [local.unique_name, each.key, "use1"])]
    } : { security = {}, arn = null, iam = {}, endpoint = null } }
  ))
}

resource "aws_secretsmanager_secret" "cluster-data-use2" {
  for_each = { for k, v in local.eks_use2 : k => k }

  description             = "cluster specific data"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "use2", "data"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "cluster-data-version-use2" {
  for_each = { for k, v in local.eks_use2 : k => k }

  secret_id = aws_secretsmanager_secret.cluster-data-use2[each.key].name
  secret_string = jsonencode(merge(
    { (each.key) = length(module.eks_us-east-1.cluster_arn) > 0 ? {
      security = { for k, v in module.eks_us-east-2.cluster_security[join("-", [local.unique_name, each.key, "use2"])] : k => v },
      iam      = { for k, v in module.eks_us-east-2.cluster_iam_role[join("-", [local.unique_name, each.key, "use2"])] : k => v },
      arn      = module.eks_us-east-2.cluster_arn[join("-", [local.unique_name, each.key, "use2"])],
      endpoint = module.eks_us-east-2.cluster_endpoint[join("-", [local.unique_name, each.key, "use2"])]
    } : { security = {}, arn = null, iam = {}, endpoint = null } }
  ))
}

resource "aws_secretsmanager_secret" "cluster-data-usw1" {
  for_each = { for k, v in local.eks_usw1 : k => k }

  description             = "cluster specific data"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "usw1", "data"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "cluster-data-version-usw1" {
  for_each = { for k, v in local.eks_usw1 : k => k }

  secret_id = aws_secretsmanager_secret.cluster-data-usw1[each.key].name
  secret_string = jsonencode(merge(
    { (each.key) = length(module.eks_us-west-1.cluster_arn) > 0 ? {
      security = { for k, v in module.eks_us-west-1.cluster_security[join("-", [local.unique_name, each.key, "usw1"])] : k => v },
      iam      = { for k, v in module.eks_us-west-1.cluster_iam_role[join("-", [local.unique_name, each.key, "usw1"])] : k => v },
      arn      = module.eks_us-west-1.cluster_arn[join("-", [local.unique_name, each.key, "usw1"])],
      endpoint = module.eks_us-west-1.cluster_endpoint[join("-", [local.unique_name, each.key, "usw1"])]
    } : { security = {}, arn = null, iam = {}, endpoint = null } }
  ))
}
resource "aws_secretsmanager_secret" "cluster-data-usw2" {
  for_each = { for k, v in local.eks_usw2 : k => k }

  description             = "cluster specific data"
  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "usw2", "data"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "cluster-data-version-usw2" {
  for_each = { for k, v in local.eks_usw2 : k => k }

  secret_id = aws_secretsmanager_secret.cluster-data-usw2[each.key].name
  secret_string = jsonencode(merge(
    { (each.key) = length(module.eks_us-west-2.cluster_arn) > 0 ? {
      security = { for k, v in module.eks_us-west-2.cluster_security[join("-", [local.unique_name, each.key, "usw2"])] : k => v },
      iam      = { for k, v in module.eks_us-west-2.cluster_iam_role[join("-", [local.unique_name, each.key, "usw2"])] : k => v },
      arn      = module.eks_us-west-2.cluster_arn[join("-", [local.unique_name, each.key, "usw2"])],
      endpoint = module.eks_us-west-2.cluster_endpoint[join("-", [local.unique_name, each.key, "usw2"])]
    } : { security = {}, arn = null, iam = {}, endpoint = null } }
  ))
}

// PRIVATE-CA ISSUER PER REGION DATA
resource "aws_secretsmanager_secret" "issuer-use1" {
  count = length(module.eks_us-east-1.cluster_arn) > 0 ? 1 : 0

  description             = "cluster issuer specific data"
  name                    = join("/", [replace(local.unique_name, "-", "/"), "use1", "issuer"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "issuer-version-use1" {
  count = length(module.eks_us-east-1.cluster_arn) > 0 ? 1 : 0

  secret_id = aws_secretsmanager_secret.issuer-use1[count.index].name
  secret_string = jsonencode(merge(
    { acmpca_role_unique_id = { for i in aws_iam_role.use1-acmpca-role : i.name => i.unique_id } },
    { acmpca_role_arn = { for i in aws_iam_role.use1-acmpca-role : i.name => i.arn } },
    { acmpca_role_policy_arn = { for policy in aws_iam_policy.use1-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) } },

    { acmpca_identity_provider_arn = { for id in aws_iam_openid_connect_provider.use1-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) } }
  ))
}

resource "aws_secretsmanager_secret" "issuer-use2" {
  count = length(module.eks_us-east-2.cluster_arn) > 0 ? 1 : 0

  description             = "cluster issuer specific data"
  name                    = join("/", [replace(local.unique_name, "-", "/"), "use2", "issuer"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "issuer-version-use2" {
  count = length(module.eks_us-east-2.cluster_arn) > 0 ? 1 : 0

  secret_id = aws_secretsmanager_secret.issuer-use2[count.index].name
  secret_string = jsonencode(merge(
    { acmpca_role_unique_id = { for i in aws_iam_role.use2-acmpca-role : i.name => i.unique_id } },
    { acmpca_role_arn = { for i in aws_iam_role.use2-acmpca-role : i.name => i.arn } },
    { acmpca_role_policy_arn = { for policy in aws_iam_policy.use2-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) } },
    { acmpca_identity_provider_arn = { for id in aws_iam_openid_connect_provider.use2-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) } }
  ))
}

resource "aws_secretsmanager_secret" "issuer-usw1" {
  count = length(module.eks_us-west-1.cluster_arn) > 0 ? 1 : 0

  description             = "cluster issuer specific data"
  name                    = join("/", [replace(local.unique_name, "-", "/"), "usw1", "issuer"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "issuer-version-usw1" {
  count = length(module.eks_us-west-1.cluster_arn) > 0 ? 1 : 0

  secret_id = aws_secretsmanager_secret.issuer-usw1[count.index].name
  secret_string = jsonencode(merge(
    { acmpca_role_unique_id = { for i in aws_iam_role.usw1-acmpca-role : i.name => i.unique_id } },
    { acmpca_role_arn = { for i in aws_iam_role.usw1-acmpca-role : i.name => i.arn } },
    { acmpca_role_policy_arn = { for policy in aws_iam_policy.usw1-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) } },
    { acmpca_identity_provider_arn = { for id in aws_iam_openid_connect_provider.usw1-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) } }
  ))
}

resource "aws_secretsmanager_secret" "issuer-usw2" {
  count = length(module.eks_us-west-2.cluster_arn) > 0 ? 1 : 0

  description             = "cluster issuer specific data"
  name                    = join("/", [replace(local.unique_name, "-", "/"), "usw2", "issuer"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "issuer-version-usw2" {
  count = length(module.eks_us-west-2.cluster_arn) > 0 ? 1 : 0

  secret_id = aws_secretsmanager_secret.issuer-usw2[count.index].name
  secret_string = jsonencode(merge(
    { acmpca_role_unique_id = { for i in aws_iam_role.usw2-acmpca-role : i.name => i.unique_id } },
    { acmpca_role_arn = { for i in aws_iam_role.usw2-acmpca-role : i.name => i.arn } },
    { acmpca_role_policy_arn = { for policy in aws_iam_policy.usw2-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) } },
    { acmpca_identity_provider_arn = { for id in aws_iam_openid_connect_provider.usw2-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) } }
  ))
}

// PRIVATE-CA ISSUER ALL REGION DATA

resource "aws_secretsmanager_secret" "issuer-all" {
  description             = "cluster issuer specific data"
  name                    = join("/", [replace(local.unique_name, "-", "/"), "all-issuer"])
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "issuer-version-all" {
  secret_id = aws_secretsmanager_secret.issuer-all.name
  secret_string = jsonencode(merge(
    { use1 = merge(
      { acmpca_role_unique_id = { for i in aws_iam_role.use1-acmpca-role : i.name => i.unique_id } },
      { acmpca_role_arn = { for i in aws_iam_role.use1-acmpca-role : i.name => i.arn } },
      { acmpca_role_policy_arn = { for policy in aws_iam_policy.use1-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) } },
      { acmpca_identity_provider_arn = { for id in aws_iam_openid_connect_provider.use1-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) } }
    ) },
    { use2 = merge(
      { acmpca_role_unique_id = { for i in aws_iam_role.use2-acmpca-role : i.name => i.unique_id } },
      { acmpca_role_arn = { for i in aws_iam_role.use2-acmpca-role : i.name => i.arn } },
      { acmpca_role_policy_arn = { for policy in aws_iam_policy.use2-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) } },
      { acmpca_identity_provider_arn = { for id in aws_iam_openid_connect_provider.use2-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) } }
    ) },
    { usw1 = merge(
      { acmpca_role_unique_id = { for i in aws_iam_role.usw1-acmpca-role : i.name => i.unique_id } },
      { acmpca_role_arn = { for i in aws_iam_role.usw1-acmpca-role : i.name => i.arn } },
      { acmpca_role_policy_arn = { for policy in aws_iam_policy.usw1-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) } },
      { acmpca_identity_provider_arn = { for id in aws_iam_openid_connect_provider.usw1-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) } }
    ) },
    { usw2 = merge(
      { acmpca_role_unique_id = { for i in aws_iam_role.usw2-acmpca-role : i.name => i.unique_id } },
      { acmpca_role_arn = { for i in aws_iam_role.usw2-acmpca-role : i.name => i.arn } },
      { acmpca_role_policy_arn = { for policy in aws_iam_policy.usw2-acmpca-policy : "${lookup(policy.tags, "cluster_name", "default")}" => (policy.arn) } },
      { acmpca_identity_provider_arn = { for id in aws_iam_openid_connect_provider.usw2-acmpca-identity : "${lookup(id.tags, "cluster_name", "default")}" => (id.arn) } }
    ) }
  ))
}

resource "aws_ssm_parameter" "cluster-arn" {
  for_each = merge(
    (module.eks_us-east-1.cluster_arn != null) ? module.eks_us-east-1.cluster_arn : {},
    (module.eks_us-east-2.cluster_arn != null) ? module.eks_us-east-2.cluster_arn : {},
    (module.eks_us-west-1.cluster_arn != null) ? module.eks_us-west-1.cluster_arn : {},
    (module.eks_us-west-2.cluster_arn != null) ? module.eks_us-west-2.cluster_arn : {}
  )

  name  = join("-", [each.key, "arn"])
  type  = "String"
  value = each.value
  tags = local.tags
}

resource "aws_ssm_parameter" "cluster-oidc-arn" {
  for_each = merge(
    (module.eks_us-east-1.cluster_oidc_provider_arn != null) ? module.eks_us-east-1.cluster_oidc_provider_arn : {},
    (module.eks_us-east-2.cluster_oidc_provider_arn != null) ? module.eks_us-east-2.cluster_oidc_provider_arn : {},
    (module.eks_us-west-1.cluster_oidc_provider_arn != null) ? module.eks_us-west-1.cluster_oidc_provider_arn : {},
    (module.eks_us-west-2.cluster_oidc_provider_arn != null) ? module.eks_us-west-2.cluster_oidc_provider_arn : {}
  )

  name  = join("-", [each.key, "oidc-provider-arn"])
  type  = "String"
  value = each.value
  tags = local.tags
}

// COMPLEX NESTED MAP, SO WE SET ONE SSM RESOURCE PER REGION CLUSTERS TO HELP SIMPLIFY THE PARAM AND THIS CODE
// TODO: we can sue the same logic as in modules/shared_eks/roles.tf where we create an iterator that is a map
// containing a key for each <region>-<cluster> combination and not have separate resources defined here for 
// each region. Create a backlog ticket to optimize this code a bit more.

/* 07-12-23 commented due to error
│ Error: updating SSM Parameter (identity-tfhello-dev-X-usw2-cluster-info): ValidationException: Standard tier parameters support a maximum parameter value of 4096 characters. To create a larger parameter value, upgrade the parameter to use the advanced-parameter tier. For more information, see https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-advanced-parameters.html
│ 	status code: 400, request id: 628d9b52-8332-4e12-bfc7-627b9b9acbcf
│ 
│   with aws_ssm_parameter.cluster-info-usw2["identity-tfhello-dev-X-usw2"],
│   on main.tf line 615, in resource "aws_ssm_parameter" "cluster-info-usw2":
│  615: resource "aws_ssm_parameter" "cluster-info-usw2" {
│ 
*/

/*
resource "aws_ssm_parameter" "cluster-info-use1" {
  for_each = { for k, v in module.eks_us-east-1.cluster_arn : k => v }

  name  = join("-", [each.key, "cluster-info"])
  type  = "String"
  value = jsonencode(merge(
    { arn = module.eks_us-east-1.cluster_arn[each.key] },
    { endpoint = module.eks_us-east-1.cluster_endpoint[each.key] },
    { name = each.key },
    { for k, v in module.eks_us-east-1.cluster_iam_role[each.key] : k => v },
    { for k, v in module.eks_us-east-1.cluster_security[each.key] : k => v },
    { for k, v in module.eks_us-east-1.cluster_node_groups[each.key] : k => v }
  ))
  tags = local.tags
}

resource "aws_ssm_parameter" "cluster-info-use2" {
  for_each = { for k, v in module.eks_us-east-2.cluster_arn : k => v }

  name  = join("-", [each.key, "cluster-info"])
  type  = "String"
  value = jsonencode(merge(
    { arn = module.eks_us-east-2.cluster_arn[each.key] },
    { endpoint = module.eks_us-east-2.cluster_endpoint[each.key] },
    { name = each.key },
    { for k, v in module.eks_us-east-2.cluster_iam_role[each.key] : k => v },
    { for k, v in module.eks_us-east-2.cluster_security[each.key] : k => v },
    { for k, v in module.eks_us-east-2.cluster_node_groups[each.key] : k => v }
  ))
  tags = local.tags
}

resource "aws_ssm_parameter" "cluster-info-usw1" {
  for_each = { for k, v in module.eks_us-west-1.cluster_arn : k => v }

  name  = join("-", [each.key, "cluster-info"])
  type  = "String"
  value = jsonencode(merge(
    { arn = module.eks_us-west-1.cluster_arn[each.key] },
    { endpoint = module.eks_us-west-1.cluster_endpoint[each.key] },
    { name = each.key },
    { for k, v in module.eks_us-west-1.cluster_iam_role[each.key] : k => v },
    { for k, v in module.eks_us-west-1.cluster_security[each.key] : k => v },
    { for k, v in module.eks_us-west-1.cluster_node_groups[each.key] : k => v }
  ))
  tags = local.tags
}

resource "aws_ssm_parameter" "cluster-info-usw2" {
  for_each = { for k, v in module.eks_us-west-2.cluster_arn : k => v }

  name  = join("-", [each.key, "cluster-info"])
  type  = "String"
  value = jsonencode(merge(
    { arn = module.eks_us-west-2.cluster_arn[each.key] },
    { endpoint = module.eks_us-west-2.cluster_endpoint[each.key] },
    { name = each.key },
    { for k, v in module.eks_us-west-2.cluster_iam_role[each.key] : k => v },
    { for k, v in module.eks_us-west-2.cluster_security[each.key] : k => v },
    { for k, v in module.eks_us-west-2.cluster_node_groups[each.key] : k => v }
  ))
  tags = local.tags
}
*/

