##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.2
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

variable "eks" {
  description = "multi-region eks cluster configuration"
  type = map(object({
    regions                           = list(string)
    cluster_name_prefix_iam_role_name = optional(bool)
    version                           = string
    enable_public_access              = optional(bool)
    enable_private_access             = optional(bool)
    kms_key_administrators            = optional(list(string))
    auth_roles = optional(list(object({
      rolearn  = string
      username = string
      groups   = list(string)
    })))
    auth_users = optional(list(object({
      userarn  = string
      username = string
      groups   = list(string)
    })))
    auth_accounts           = optional(list(string))
    eks_managed_node_groups = map(any)
    eks_managed_node_group_defaults = object({
      instance_types = list(string)
    })
    vpc_id         = map(any)
    subnet_ids     = map(list(string))
    cluster_addons = map(map(any))
    roles_resource_overrides = optional(map(any))
  }))
  default = null

  validation {
    condition     = length(var.eks) >= 1
    error_message = "map must contain at least one item"
  }
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
