##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "s3_bucket" {
  for_each = var.s3

  source = "git::git@github.com:thetoolsmith/tf-project-bootstrap/shared/modules/s3?ref=main"

  product            = var.product
  purpose            = each.key
  environment        = var.environment
  region             = var.aws_region[split(".", each.value.provider)[1]]
  tags               = var.tags
  short_region       = split(".", each.value.provider)[1]
  enable_replication = each.value.enable_replication
  replica_config     = each.value.replica_config
  replica_region     = var.aws_region[split(".", each.value.provider)[1]] //used for resource name only ATM
}
