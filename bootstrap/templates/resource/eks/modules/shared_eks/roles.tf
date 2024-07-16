##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

locals {
  cluster_roles = flatten([
    for role, role_data in var.roles : [
      for cluster, cluster_data in module.eks : {
        cluster_name = cluster_data.cluster_name
        cluster_data = cluster_data
        roles_resource_overrides = lookup(var.cluster[tostring(cluster)], "roles_resource_overrides", null) == null ? {} : (lookup(var.cluster[tostring(cluster)].roles_resource_overrides, tostring(role), null) != null ? var.cluster[tostring(cluster)].roles_resource_overrides[tostring(role)] : {})
        role_name = role
        role_data = role_data
      }
    ]
  ])
}

data "aws_caller_identity" "this" {}


data "aws_iam_policy_document" "iam-assume-policy-document" {
  for_each = {
    for cr in local.cluster_roles : "${cr.role_name}-${cr.cluster_name}" => cr
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [each.value.cluster_data.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = each.value.role_data.operator
      variable = join(":", [each.value.cluster_data.oidc_provider, "sub"])
      values = [join(":", ["system:serviceaccount", each.value.role_data.namespace, each.value.role_data.service_account])]
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = {
    for cr in local.cluster_roles : "${cr.role_name}-${cr.cluster_name}" => cr
  }

  name               = join("-", [each.value.cluster_data.cluster_name, each.value.role_name])
  assume_role_policy = data.aws_iam_policy_document.iam-assume-policy-document[each.key].json
  tags               = var.tags
}

data "aws_iam_policy_document" "iam-policy-document" {
  for_each = {
    for cr in local.cluster_roles : "${cr.role_name}-${cr.cluster_name}" => cr
  }

  dynamic "statement" {
    for_each = [for s in each.value.role_data.statements : {
      effect    = s.effect
      actions   = s.actions
      sid       = s.sid
      resources = (each.value.roles_resource_overrides != {}) ? ((length(each.value.roles_resource_overrides[s.sid]) != 0) ? each.value.roles_resource_overrides[s.sid] : s.resources) : s.resources
    }]
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      sid       = statement.value.sid
      resources = [
        for r in statement.value.resources : replace(replace(replace(r, "__CLUSTER_NAME__", each.value.cluster_name), "__CLUSTER_IAM__", data.aws_caller_identity.this.account_id), "__UNIQUE_NAME__", join("/", [lookup(var.tags, "owner", "unknown"), lookup(var.tags, "product", "unknown"), lookup(var.tags, "environment", "unknown")]))
      ]
    }
  }
}

resource "aws_iam_policy" "this" {
  for_each = {
    for cr in local.cluster_roles : "${cr.role_name}-${cr.cluster_name}" => cr
  }

  name        = join("-", [each.value.cluster_name, each.value.role_name, "role-policy"])
  description = join(" ", ["eks", each.value.role_name, "role policy"])
  policy      = data.aws_iam_policy_document.iam-policy-document[each.key].json

  tags = merge(var.tags, {
    "cluster_name" = each.value.cluster_name
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = {
    for cr in local.cluster_roles : "${cr.role_name}-${cr.cluster_name}" => cr
  }

  role       = aws_iam_role.this[each.key].name
  policy_arn = aws_iam_policy.this[each.key].arn
}

resource "aws_secretsmanager_secret" "role-arn" {
  for_each = {
    for cr in local.cluster_roles : "${cr.role_name}-${cr.cluster_name}" => cr
  }

  description             = "additional role arn for eks cluster (not the cluster roles itself)"
  name                    = join("/", [replace(var.unique_name, "-", "/"), each.value.cluster_name, each.value.role_name, "role-arn"])
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "role-arn-version" {
  for_each = {
    for cr in local.cluster_roles : "${cr.role_name}-${cr.cluster_name}" => cr
  }

  secret_id     = aws_secretsmanager_secret.role-arn[each.key].name
  secret_string = aws_iam_role.this[each.key].arn
}

