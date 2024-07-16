##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
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
