##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

provider "aws" {
  alias   = "acmpca"
  region  = "us-east-1"
  profile = "acmpca"
  shared_config_files = ["../../.aws/config"]
  shared_credentials_files = ["../../.aws/credentials"]
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"

  // using default tags in provider causes terraform to always show changes on these.
  // might be because we re-use this provider

  //  default_tags {
  //    tags = {
  //      environment = local.environment
  //      product     = local.product
  //    }
  //  }
}

provider "aws" {
  alias  = "use2"
  region = var.aws_region["use2"]
}

provider "aws" {
  alias  = "usw1"
  region = var.aws_region["usw1"]
}

provider "aws" {
  alias  = "usw2"
  region = var.aws_region["usw2"]
}

provider "aws" {
  alias  = "usc1"
  region = var.aws_region["usc1"]
}

provider "aws" {
  alias  = "usc2"
  region = var.aws_region["usc2"]
}

/* ADD ADDITIONAL ACCOUNT AND/OR REGION PROVIDERS AS NEEDED HERE */
