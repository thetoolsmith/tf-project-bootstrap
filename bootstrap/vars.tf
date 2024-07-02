variable "environment" {
  description = "bootstrapped environment name"
  type        = string
  default     = "dev"
}

variable "product" {
  description = "product or product suite"
  type        = string
  default     = null
}

variable "required_tags" {
  type = object({
    product        = string
    owner          = string
    organization   = string
    environment    = string
    description    = string
    site           = string
    purpose        = string
    classification = string
    email          = string
  })
}

variable "mcrypt_key" {
  description = "bootstrap state encryption key"
  type        = string
  default     = null
}

variable "optional_tags" {
  type = object({})
}

variable "region" {
  type = string
}

variable "short_region" {
  description = "used to map region abbreviations to actual region names"
  type        = map(any)
}

variable "replica_region" {
  description = "map region to default resource replication region"
  type        = map(any)
  default = {
    us-east-1 = "us-west-2"
    us-east-2 = "us-west-1"
    us-west-1 = "us-east-2"
    us-west-2 = "us-east-1"
  }
}

variable "enable_replication" {
  description = "Toggle to optionally enable replication"
  type        = bool
  default     = false
}

variable "replica_config" {
  description = "configuration for s3 replication"
  type = object({
    rules = list(object({
      rule_id = string
      status = bool
      storage_class = string
      filters = list(object({
        prefix = string
      }))
    }))
  })
  default = null
}
