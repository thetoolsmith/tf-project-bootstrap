##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

locals {
  environment = var.environment
  product     = var.product

  tags = merge(tomap(var.required_tags), tomap(var.optional_tags))

  s3_use1 = length(var.s3) > 0 ? { for k, v in var.s3 : k => v if v["provider"] == "aws.use1" } : {}
  s3_usw1 = length(var.s3) > 0 ? { for k, v in var.s3 : k => v if v["provider"] == "aws.usw1" } : {}
  s3_usw2 = length(var.s3) > 0 ? { for k, v in var.s3 : k => v if v["provider"] == "aws.usw2" } : {}
  s3_use2 = length(var.s3) > 0 ? { for k, v in var.s3 : k => v if v["provider"] == "aws.use2" } : {}

  total_buckets = sum([
    length(local.s3_use1),
    length(local.s3_use2),
    length(local.s3_usw1),
    length(local.s3_usw2)
  ])

  unique_id           = (local.total_buckets > 0) ? random_string.id[0].result : null
  unique_name         = join("-", [local.tags.owner, local.product, local.environment])
  secrets_unique_name = (local.total_buckets > 0) ? join("-", [local.unique_name, local.unique_id]) : null
}

resource "random_string" "id" {
  count   = (local.total_buckets > 0) ? 1 : 0
  length  = 4
  special = false
  upper   = false
  lower   = true
}
