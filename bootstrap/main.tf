module "backend" {
  source = "git::git@github.com:thetoolsmith/tf-project-bootstrap/shared//modules/s3?ref=main"

  product       = local.product
  purpose       = local.purpose
  environment   = local.environment
  region        = var.region
  tags = local.tags
  short_region  = "use1"
  enable_replication = false
  replica_config     = { rules = [] }
  replica_region     = "us-west-2"
}

resource "aws_secretsmanager_secret" "bootstrapped-state" {
  name                    = join("/", [replace(local.secrets_unique_name, "-", "/"), "bootstrap-tf-state"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bootstrapped-state-version" {
  secret_id     = aws_secretsmanager_secret.bootstrapped-state.id
  secret_string = module.backend.bucket_id
}

resource "aws_secretsmanager_secret" "mcrypt-key" {
  name                    = join("/", [replace(local.secrets_unique_name, "-", "/"), "bootstrap-mcrypt-key"])
  recovery_window_in_days = 0

}

resource "aws_secretsmanager_secret_version" "mcrypt-key" {
  secret_id     = aws_secretsmanager_secret.mcrypt-key.id
  secret_string = local.mcrypt_key
}

resource "aws_secretsmanager_secret" "bucket-id" {
  name                    = join("/", [replace(local.secrets_unique_name, "-", "/"), "bucket-id"])
  recovery_window_in_days = 0
}

// fwiw, bucket name and ID are the same value in aws

resource "aws_secretsmanager_secret_version" "bucket-id" {
  secret_id     = aws_secretsmanager_secret.bucket-id.id
  secret_string = module.backend.bucket_id
}

resource "aws_secretsmanager_secret" "bucket-domain-name" {
  name                    = join("/", [replace(local.secrets_unique_name, "-", "/"), "bucket-domain-name"])
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bucket-domain-name" {
  secret_id     = aws_secretsmanager_secret.bucket-domain-name.id
  secret_string = module.backend.bucket_domain_name
}
