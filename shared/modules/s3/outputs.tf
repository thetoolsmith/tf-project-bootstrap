output "data" {
  value = merge(aws_s3_bucket.bucket, aws_kms_key.bucket-key)
}

output "bucket_purpose" {
  value = var.purpose
}

output "bucket_region" {
  value = var.region
}

output "bucket_id" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_encryption_key_arn" {
  value = aws_kms_key.bucket-key.arn
}

output "bucket_encryption_key_id" {
  value = aws_kms_key.bucket-key.id
}

output "bucket_encryption_key_rotation_enabled" {
  value = aws_kms_key.bucket-key.enable_key_rotation
}

output "bucket_encryption_key_deletion_days" {
  value = aws_kms_key.bucket-key.deletion_window_in_days
}

output "bucket_encryption_key_multi_region" {
  value = aws_kms_key.bucket-key.multi_region
}

output "bucket_encryption_key_usage" {
  value = aws_kms_key.bucket-key.key_usage
}

output "bucket_encryption_key_policy" {
  value = aws_kms_key.bucket-key.policy
}
