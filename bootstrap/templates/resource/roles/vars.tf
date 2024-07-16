##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

variable "cluster_name" {
  description = "valid aws eks cluster name"
  type        = string
  default     = null
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

variable "roles" {
  description = "map of role configurations"
  type = map(object({
    statements = list(object({
      effect = string
      sid    = string
      resources = list(string)
      actions = list(string)
    }))
  }))
  default = null
}
