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

variable "unique_name" {
  description = "unique name prefix for resource. Example owner-product-environment"
  type        = string
  default     = null

  validation {
    condition     = length(var.unique_name) >= 5
    error_message = "The unique_name must be at least 5 characters."
  }
}

variable "tags" {
  description = "collection or required and optional tags to apply to all resources"
  type        = map(string)
}

variable "cluster" {
  description = "map of cluster configurations that all have the same deploy region"
  type        = map(any)
  default     = null
}

variable "roles" {
  description = "map of role configurations"
  type = map(object({
    operator = string
    namespace = string
    service_account = string
    statements = list(object({
      effect = string
      sid    = string
      resources = list(string)
      actions = list(string)
    }))
  }))
  default = null
}
