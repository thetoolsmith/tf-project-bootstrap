provider "aws" {
  alias  = "use1"
  region = "us-east-1" 
  default_tags {
    tags = {
      environment = local.environment
      product     = local.product
    }
  }
}

provider "aws" {
  alias  = "use2"
  region = var.aws_region["use2"]
  default_tags {
    tags = {
      environment = local.environment
      product     = local.product
    }
  }
}

provider "aws" {
  alias  = "usw1"
  region = var.aws_region["usw1"]
  default_tags {
    tags = {
      environment = local.environment
      product     = local.product
    }
  }
}

provider "aws" {
  alias  = "usw2"
  region = var.aws_region["usw2"]
  default_tags {
    tags = {
      environment = local.environment
      product     = local.product
    }
  }
}

provider "aws" {
  alias  = "usc1"
  region = var.aws_region["usc1"]
  default_tags {
    tags = {
      environment = local.environment
      product     = local.product
    }
  }
}

provider "aws" {
  alias  = "usc2"
  region = var.aws_region["usc2"]
  default_tags {
    tags = {
      environment = local.environment
      product     = local.product
    }
  }
}

/* ADD ADDITIONAL ACCOUNT AND/OR REGION PROVIDERS AS NEEDED HERE */
