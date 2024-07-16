##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

output "bucket_id" {
  value = (length(merge(
    module.s3_us-east-1.id,
    module.s3_us-west-2.id,
    module.s3_us-east-2.id,
    module.s3_us-west-1.id
    )) > 0) ? merge(
    module.s3_us-east-1.id,
    module.s3_us-west-2.id,
    module.s3_us-east-2.id,
  module.s3_us-west-1.id) : null
}

output "bucket_domain_name" {
  value = (length(merge(
    module.s3_us-east-1.domain_name,
    module.s3_us-west-2.domain_name,
    module.s3_us-east-2.domain_name,
    module.s3_us-west-1.domain_name
    )) > 0) ? merge(
    module.s3_us-east-1.domain_name,
    module.s3_us-west-2.domain_name,
    module.s3_us-east-2.domain_name,
  module.s3_us-west-1.domain_name) : null
}

output "bucket_encryption_key_arn" {
  value = (length(merge(
    module.s3_us-east-1.encryption_key_arn,
    module.s3_us-west-2.encryption_key_arn,
    module.s3_us-east-2.encryption_key_arn,
    module.s3_us-west-1.encryption_key_arn
    )) > 0) ? merge(
    module.s3_us-east-1.encryption_key_arn,
    module.s3_us-west-2.encryption_key_arn,
    module.s3_us-east-2.encryption_key_arn,
  module.s3_us-west-1.encryption_key_arn) : null
}

output "bucket_encryption_key_id" {
  value = (length(merge(
    module.s3_us-east-1.encryption_key_id,
    module.s3_us-west-2.encryption_key_id,
    module.s3_us-east-2.encryption_key_id,
    module.s3_us-west-1.encryption_key_id
    )) > 0) ? merge(
    module.s3_us-east-1.encryption_key_id,
    module.s3_us-west-2.encryption_key_id,
    module.s3_us-east-2.encryption_key_id,
  module.s3_us-west-1.encryption_key_id) : null
}

output "bucket_encryption_key_rotation_enabled" {
  value = (length(merge(
    module.s3_us-east-1.encryption_key_rotation_enabled,
    module.s3_us-west-2.encryption_key_rotation_enabled,
    module.s3_us-east-2.encryption_key_rotation_enabled,
    module.s3_us-west-1.encryption_key_rotation_enabled
    )) > 0) ? merge(
    module.s3_us-east-1.encryption_key_rotation_enabled,
    module.s3_us-west-2.encryption_key_rotation_enabled,
    module.s3_us-east-2.encryption_key_rotation_enabled,
  module.s3_us-west-1.encryption_key_rotation_enabled) : null
}

output "bucket_encryption_key_deletion_days" {
  value = (length(merge(
    module.s3_us-east-1.encryption_key_deletion_days,
    module.s3_us-west-2.encryption_key_deletion_days,
    module.s3_us-east-2.encryption_key_deletion_days,
    module.s3_us-west-1.encryption_key_deletion_days
    )) > 0) ? merge(
    module.s3_us-east-1.encryption_key_deletion_days,
    module.s3_us-west-2.encryption_key_deletion_days,
    module.s3_us-east-2.encryption_key_deletion_days,
  module.s3_us-west-1.encryption_key_deletion_days) : null
}

output "bucket_encryption_key_multi_region" {
  value = (length(merge(
    module.s3_us-east-1.encryption_key_multi_region,
    module.s3_us-west-2.encryption_key_multi_region,
    module.s3_us-east-2.encryption_key_multi_region,
    module.s3_us-west-1.encryption_key_multi_region
    )) > 0) ? merge(
    module.s3_us-east-1.encryption_key_multi_region,
    module.s3_us-west-2.encryption_key_multi_region,
    module.s3_us-east-2.encryption_key_multi_region,
  module.s3_us-west-1.encryption_key_multi_region) : null
}

output "bucket_encryption_key_usage" {
  value = (length(merge(
    module.s3_us-east-1.encryption_key_usage,
    module.s3_us-west-2.encryption_key_usage,
    module.s3_us-east-2.encryption_key_usage,
    module.s3_us-west-1.encryption_key_usage
    )) > 0) ? merge(
    module.s3_us-east-1.encryption_key_usage,
    module.s3_us-west-2.encryption_key_usage,
    module.s3_us-east-2.encryption_key_usage,
  module.s3_us-west-1.encryption_key_usage) : null
}

output "bucket_encryption_key_policy" {
  value = (length(merge(
    module.s3_us-east-1.encryption_key_policy,
    module.s3_us-west-2.encryption_key_policy,
    module.s3_us-east-2.encryption_key_policy,
    module.s3_us-west-1.encryption_key_policy
    )) > 0) ? merge(
    module.s3_us-east-1.encryption_key_policy,
    module.s3_us-west-2.encryption_key_policy,
    module.s3_us-east-2.encryption_key_policy,
  module.s3_us-west-1.encryption_key_policy) : null
}

//this is good for debugging
//output "s3_data" {
//  value = merge(
//    module.s3_us-east-1.data,
//    module.s3_us-east-2.data,
//    module.s3_us-west-1.data,
//    module.s3_us-west-2.data
//  )
//}
