resource "aws_kms_key" "bucket-key" {
  description             = "This key is used to encrypt state bucket objects"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_kms_alias" "key-alias" {
  name          = join("/", ["alias", local.unique_name])
  target_key_id = aws_kms_key.bucket-key.key_id
}


resource "random_integer" "id" {
  max = 999
  min = 100
}

data "aws_iam_policy_document" "iam-bucket-policy" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.bucket.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "iam-policy" {
  name        = join("-", [aws_s3_bucket.bucket.id, "policy"])
  description = "basic policy for s3 bucket"
  policy      = data.aws_iam_policy_document.iam-bucket-policy.json
  tags        = local.tags
}

resource "aws_s3_bucket" "bucket" {
  bucket        = join("-", [local.unique_name, var.region])
  force_destroy = true
  tags          = local.tags
  lifecycle {
    // prevent_destroy = true
    ignore_changes = [
      server_side_encryption_configuration
    ]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-sse" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket-version" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-public-access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf-lock" {
  name           = join("-", [local.unique_name, var.region])
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
