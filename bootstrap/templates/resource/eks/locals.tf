##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

locals {
  environment = var.environment
  product     = var.product
  unique_id   = random_string.id.result
  tags        = merge(tomap(var.required_tags), tomap(var.optional_tags))

  unique_name         = join("-", [local.tags.owner, local.product, local.environment])
  secrets_unique_name = join("-", [local.unique_name, local.unique_id])

  eks_use1 = length(var.eks) > 0 ? { for k, v in var.eks : k => v if contains(v["regions"], "us-east-1") } : {}
  eks_usw1 = length(var.eks) > 0 ? { for k, v in var.eks : k => v if contains(v["regions"], "us-west-1") } : {}
  eks_usw2 = length(var.eks) > 0 ? { for k, v in var.eks : k => v if contains(v["regions"], "us-west-2") } : {}
  eks_use2 = length(var.eks) > 0 ? { for k, v in var.eks : k => v if contains(v["regions"], "us-east-2") } : {}

  clusters = length(var.eks) > 0 ? { for k, v in var.eks : k => k } : {}

}

resource "random_string" "id" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}
