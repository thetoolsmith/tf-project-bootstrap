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

variable "purpose" {
  description = "how is this resource being used"
  type        = string
  default     = null

  validation {
    condition     = length(var.purpose) != null
    error_message = "purpose cannot be null"
  }
}

variable "tags" {
  description = "map of required and optional tags"
  type = map(string)
}

variable "region" {
  description = "valid supported aws region"
  type        = string

  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.region)
    error_message = "region is not supported."
  }
}

variable "short_region" {
  description = "region short abbreviation"
  type        = string
}

variable "replica_region" {
  description = "region to create s3 replica"
  type        = string
  default     = "us-west-2"
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
      status = string
      storage_class = string
      filters = list(object({
        prefix = string
      }))
    }))
  })
  default = null
}
