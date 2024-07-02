locals {
  environment = var.environment
  product     = var.product
  purpose     = replace(replace(var.purpose, " ", ""), "/", "-")
  unique_id   = random_string.id.result
  tags = merge(tomap(var.required_tags),
    merge(var.optional_tags, {
      "environment" = var.environment
      "product"     = var.product
      "purpose"     = local.purpose
    })
  )

  unique_name = join("-", [local.tags.owner, local.product, local.environment, local.purpose])
  secrets_unique_name = join("-", [local.unique_name, local.unique_id])
}

resource "random_string" "id" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}
