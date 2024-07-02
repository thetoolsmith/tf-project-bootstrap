variable "environment" {
  description = "environment name"
  type        = string
  default     = "dev"
}

variable "product" {
  description = "product or product suite"
  type        = string
  default     = null
}

variable "purpose" {
  description = "how is this resource being used"
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

variable "optional_tags" {
  type = object({})
}

variable "region" {
  type = string
}

variable "replica_region" {
  type    = string
  default = "us-west-2"
}

variable "short_region" {
  description = "used to map region abbreviations to actual region names"
  type        = string
}

variable "source-bucket-arn" {
  description = "source bucket for creating replica"
  type        = string
  default     = null
}

variable "replica_config" {
  description = "configuration for s3 replication"
  type = object({
    rules = list(object({
      rule_id = string
      status = string
      storage_class = string
      filters = list(object({
        prefix = string
      }))
    }))
  })
  default = null
}
