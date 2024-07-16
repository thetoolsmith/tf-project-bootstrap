##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

data "aws_iam_policy_document" "iam-assume-policy-document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.cluster_oidc_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringLike"
      variable = join(":", [local.cluster_oidc_provider, "sub"])
      values = [local.cluster_oidc_provider]
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name               = join("-", [var.cluster_name, each.key])
  assume_role_policy = data.aws_iam_policy_document.iam-assume-policy-document.json
  tags               = local.tags
}

data "aws_iam_policy_document" "iam-policy-document" {
  for_each = var.roles

  dynamic "statement" {
    for_each = [for s in each.value.statements : { 
      effect    = s.effect
      actions   = s.actions
      sid       = s.sid
      resources = s.resources
    }]
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      sid       = statement.value.sid
      resources = statement.value.resources 
    }
  }
}

resource "aws_iam_policy" "this" {
  for_each = var.roles

  name        = join("-", [var.cluster_name, each.key, "role-policy"])
  description = join(" ", ["eks", each.key, "role policy"])
  policy      = data.aws_iam_policy_document.iam-policy-document[each.key].json

  tags = merge(local.tags, {
    "cluster_name" = var.cluster_name
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.roles

  role       = aws_iam_role.this[each.key].name
  policy_arn = aws_iam_policy.this[each.key].arn
}

