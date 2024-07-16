##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

terraform {
  backend "s3" {}
}

module "s3_us-west-2" {
  source = "./modules/shared_s3"

  providers = {
    aws = aws.usw2
  }

  s3             = local.s3_usw2
  product        = local.product
  environment    = local.environment
  aws_region     = var.aws_region
  replica_region = var.replica_region
  tags           = local.tags
}

module "s3_us-west-1" {
  source = "./modules/shared_s3"

  providers = {
    aws = aws.usw1
  }

  s3             = local.s3_usw1
  product        = local.product
  environment    = local.environment
  aws_region     = var.aws_region
  replica_region = var.replica_region
  tags           = local.tags
}

module "s3_us-east-1" {
  source = "./modules/shared_s3"

  providers = {
    aws = aws.use1
  }

  s3             = local.s3_use1
  product        = local.product
  environment    = local.environment
  aws_region     = var.aws_region
  replica_region = var.replica_region
  tags           = local.tags
}

module "s3_us-east-2" {
  source = "./modules/shared_s3"

  providers = {
    aws = aws.use2
  }

  s3             = local.s3_use2
  product        = local.product
  environment    = local.environment
  aws_region     = var.aws_region
  replica_region = var.replica_region
  tags           = local.tags
}

resource "aws_secretsmanager_secret" "use1-domain-name" {
  for_each = { for purpose in module.s3_us-east-1.purpose : purpose => purpose }

  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "domain_name"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "use1-domain-name-version" {
  for_each = { for purpose in module.s3_us-east-1.purpose : purpose => purpose }

  secret_id     = aws_secretsmanager_secret.use1-domain-name[each.key].name
  secret_string = jsonencode(module.s3_us-east-1.domain_name[each.key])
}

resource "aws_secretsmanager_secret" "use2-domain-name" {
  for_each = { for purpose in module.s3_us-east-2.purpose : purpose => purpose }

  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "domain_name"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "use2-domain-name-version" {
  for_each = { for purpose in module.s3_us-east-2.purpose : purpose => purpose }

  secret_id     = aws_secretsmanager_secret.use2-domain-name[each.key].name
  secret_string = jsonencode(module.s3_us-east-2.domain_name[each.key])
}

resource "aws_secretsmanager_secret" "usw1-domain-name" {
  for_each = { for purpose in module.s3_us-west-1.purpose : purpose => purpose }

  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "domain_name"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "usw1-domain-name-version" {
  for_each = { for purpose in module.s3_us-west-1.purpose : purpose => purpose }

  secret_id     = aws_secretsmanager_secret.usw1-domain-name[each.key].name
  secret_string = jsonencode(module.s3_us-west-1.domain_name[each.key])
}

resource "aws_secretsmanager_secret" "usw2-domain-name" {
  for_each = { for purpose in module.s3_us-west-2.purpose : purpose => purpose }

  name                    = join("/", [replace(local.unique_name, "-", "/"), each.key, "domain_name"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "usw2-domain-name-version" {
  for_each = { for purpose in module.s3_us-west-2.purpose : purpose => purpose }

  secret_id     = aws_secretsmanager_secret.usw2-domain-name[each.key].name
  secret_string = jsonencode(module.s3_us-west-2.domain_name[each.key])
}

// ROLLUP BLOCK SECRETS

// ALL REGION

resource "aws_secretsmanager_secret" "encryption-key-arns" {
  count = (local.total_buckets > 0) ? 1 : 0

  name                    = join("/", [replace(local.unique_name, "-", "/"), "encryption-key-arns"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "encryption-key-arns-version" {
  count = (local.total_buckets > 0) ? 1 : 0

  secret_id = aws_secretsmanager_secret.encryption-key-arns[0].name
  secret_string = jsonencode(merge(
    module.s3_us-east-1.encryption_key_arn,
    module.s3_us-east-2.encryption_key_arn,
    module.s3_us-west-1.encryption_key_arn,
    module.s3_us-west-2.encryption_key_arn
  ))
}

resource "aws_secretsmanager_secret" "s3-info" {
  count = (local.total_buckets > 0) ? 1 : 0

  name                    = join("/", [replace(local.unique_name, "-", "/"), "s3-info"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "s3-info-version" {
  count = (local.total_buckets > 0) ? 1 : 0

  secret_id = aws_secretsmanager_secret.s3-info[0].name
  secret_string = jsonencode(flatten([
    jsonencode(module.s3_us-east-1),
    jsonencode(module.s3_us-east-2),
    jsonencode(module.s3_us-west-1),
    jsonencode(module.s3_us-west-2)
  ]))
}

// REGION SPECIFIC

resource "aws_secretsmanager_secret" "s3-use1-info" {
  count = (length(local.s3_use1) > 0) ? 1 : 0

  name                    = join("/", [replace(local.unique_name, "-", "/"), "us-east-1", "s3-info"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "s3-use1-info-version" {
  count = (length(local.s3_use1) > 0) ? 1 : 0

  secret_id     = aws_secretsmanager_secret.s3-use1-info[0].name
  secret_string = jsonencode({ for k, v in module.s3_us-east-1 : k => jsonencode(v) })
}

resource "aws_secretsmanager_secret" "s3-use2-info" {
  count = (length(local.s3_use2) > 0) ? 1 : 0

  name                    = join("/", [replace(local.unique_name, "-", "/"), "us-east-2", "s3-info"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "s3-use2-info-version" {
  count = (length(local.s3_use2) > 0) ? 1 : 0

  secret_id     = aws_secretsmanager_secret.s3-use2-info[0].name
  secret_string = jsonencode({ for k, v in module.s3_us-east-2 : k => jsonencode(v) })
}

resource "aws_secretsmanager_secret" "s3-usw1-info" {
  count = (length(local.s3_usw1) > 0) ? 1 : 0

  name                    = join("/", [replace(local.unique_name, "-", "/"), "us-west-1", "s3-info"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "s3-usw1-info-version" {
  count = (length(local.s3_usw1) > 0) ? 1 : 0

  secret_id     = aws_secretsmanager_secret.s3-usw1-info[0].name
  secret_string = jsonencode({ for k, v in module.s3_us-west-1 : k => jsonencode(v) })
}

resource "aws_secretsmanager_secret" "s3-usw2-info" {
  count = (length(local.s3_usw2) > 0) ? 1 : 0

  name                    = join("/", [replace(local.unique_name, "-", "/"), "us-west-2", "s3-info"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "s3-usw2-info-version" {
  count = (length(local.s3_usw2) > 0) ? 1 : 0

  secret_id     = aws_secretsmanager_secret.s3-usw2-info[0].name
  secret_string = jsonencode({ for k, v in module.s3_us-west-2 : k => jsonencode(v) })
}
