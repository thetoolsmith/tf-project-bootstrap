##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

variable "environment" {
  description = "environment name"
  type        = string
  default     = null

  validation {
    condition     = length(var.environment) != null
    error_message = "environment cannot be null"
  }
}

variable "product" {
  description = "product or product suite"
  type        = string
  default     = null

  validation {
    condition     = length(var.product) > 1
    error_message = "product length must be greater than 1"
  }
}

variable "required_tags" {
  description = "required tags on all resources"

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
  description = "optional tags to add to all resources"
  type        = object({})
}

variable "aws_region" {
  description = "used to map region abbreviations to aws region names"
  type        = map(any)

  validation {
    condition     = length(var.aws_region) >= 1
    error_message = "map must contain at least one item"
  }
}

variable "short_region" {
  description = "used to map region names to abbreviations"
  type        = map(any)

  validation {
    condition     = length(var.short_region) >= 1
    error_message = "map must contain at least one item"
  }
}

variable "replica_region" {
  description = "map region to default resource replication region"
  type        = map(any)

  validation {
    condition     = length(var.replica_region) >= 1
    error_message = "map must contain at least one item"
  }
}

variable "s3" {
  description = "map of s3 bucket configurations regardless of region"
  type = map(object({
    enable_replication = bool
    provider           = string
    replica_config = object({
      rules = list(object({
        rule_id       = string
        status        = string
        storage_class = string
        filters = list(object({
          prefix = string
        }))
      }))
    })
  }))
  default = null
}
