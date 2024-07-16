##################################
# auto-generated resource template
# BOOTSTRAP VERSION: 0.0.3
##################################

output "purpose" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_purpose
  }
}

output "id" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_id
  }
}

output "domain_name" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_domain_name
  }
}

output "encryption_key_arn" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_encryption_key_arn
  }
}

output "encryption_key_id" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_encryption_key_id
  }
}

output "encryption_key_rotation_enabled" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_encryption_key_rotation_enabled
  }
}

output "encryption_key_deletion_days" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_encryption_key_deletion_days
  }
}

output "encryption_key_multi_region" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_encryption_key_multi_region
  }
}

output "encryption_key_usage" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_encryption_key_usage
  }
}

output "encryption_key_policy" {
  value = {
    for instance in module.s3_bucket :
    instance.bucket_purpose => instance.bucket_encryption_key_policy
  }
}

// for debugging purposes. it gives all the aws resource metadata
//output "data" {
//  value = {
//    for instance in module.s3_bucket :
//    instance.bucket_purpose => instance.data
//  }
//}

