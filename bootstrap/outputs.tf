output "s3_bucket_id" {
  value = module.backend.bucket_id
}

output "unique_id" {
  value = local.unique_id
}

output "s3_bucket_domain_name" {
  value = module.backend.bucket_domain_name
}

output "s3_bucket_encryption_key_arn" {
  value = module.backend.bucket_encryption_key_arn
}

output "s3_bucket_encryption_key_id" {
  value = module.backend.bucket_encryption_key_id
}

output "s3_bucket_encryption_key_rotation_enabled" {
  value = module.backend.bucket_encryption_key_rotation_enabled
}

output "s3_bucket_encryption_key_deletion_days" {
  value = module.backend.bucket_encryption_key_deletion_days
}

output "s3_bucket_encryption_key_multi_region" {
  value = module.backend.bucket_encryption_key_multi_region
}

output "s3_bucket_encryption_key_usage" {
  value = module.backend.bucket_encryption_key_usage
}

output "s3_bucket_encryption_key_policy" {
  value = module.backend.bucket_encryption_key_policy
}
