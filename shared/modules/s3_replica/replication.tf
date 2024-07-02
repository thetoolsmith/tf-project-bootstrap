data "aws_region" "current" {}


/* CREATE THIS IN s3 module WHEN enable_replication = true
resource "aws_iam_role" "source" {
  name = join("-", [local.unique_name, "iam-role-source", var.region])

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}
*/



resource "aws_iam_role" "replica" {
  name = join("-", [local.unique_name, "iam-role-replica", var.replica_region])

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

/* CREATE THIS IN s3 module WHEN enable_replication = true
resource "aws_iam_policy" "source" {
  name = join("-", [local.unique_name, "iam-role-source-policy", var.region])

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.source-bucket-arn}/*",
        "${var.source-bucket-arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.source-bucket-arn}/*",
        "${var.source-bucket-arn}"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.replica.arn}/*",
        "${aws_s3_bucket.replica.arn}"
      ]
    }
  ]
}
POLICY
}
*/



resource "aws_iam_policy" "replica" {
  name = join("-", [local.unique_name, "iam-role-replica-policy", var.replica_region])

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.replica.arn}/*",
        "${aws_s3_bucket.replica.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.replica.arn}/*",
        "${aws_s3_bucket.replica.arn}"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.source-bucket-arn}/*",
        "${var.source-bucket-arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "replica" {
  bucket = join("-", [local.unique_name, var.replica_region, "replica"])
}

resource "aws_s3_bucket_versioning" "replica" {
  bucket = aws_s3_bucket.replica.id
  versioning_configuration {
    status = "Enabled"
  }
}



/* CREATE THIS IN s3 module WHEN enable_replication = true
resource "aws_iam_role_policy_attachment" "source" {
  count = var.enable_replication ? 1 : 0

  role       = aws_iam_role.source[count.index].name
  policy_arn = aws_iam_policy.source[count.index].arn
}
*/



resource "aws_iam_role_policy_attachment" "replica" {
  role       = aws_iam_role.replica.name
  policy_arn = aws_iam_policy.replica.arn
}

resource "aws_kms_key" "replica" {
  description             = "This key is used to encrypt source bucket to replica transactions"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region            = true
  tags                    = local.tags
}

resource "aws_kms_alias" "replica" {
  name          = join("/", ["alias", join("-", [local.unique_name, "replica"])])
  target_key_id = aws_kms_key.replica.key_id
}

resource "aws_s3_bucket_replication_configuration" "replica_to_source" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.replica]

  role   = aws_iam_role.replica.arn
  bucket = aws_s3_bucket.replica.id

  dynamic "rule" {
    for_each = ((var.replica_config != null ? (var.replica_config.rules != null) : false) ? [for r in var.replica_config.rules : {
      rule_id       = r.rule_id
      filters       = r.filters
      status        = r.status
      storage_class = r.storage_class
    }] : [])
    content {
      id = rule.value.rule_id
      status = rule.value.status
      priority = index(var.replica_config.rules, rule.value)

      delete_marker_replication {
        status = "Enabled"
      }

      source_selection_criteria {
        replica_modifications {
          status = "Enabled"
        }
        sse_kms_encrypted_objects {
          status = "Enabled"
        }
      }

      destination {
        bucket        = aws_s3_bucket.bucket.arn
        storage_class = rule.value.storage_class
        encryption_configuration {
          replica_kms_key_id = var.source-bucket-key-arn
        }
      }

      dynamic "filter" {
        for_each = [for f in rule.value.filters : {
          thefilter = f
        }]
        content {
          prefix = filter.value.thefilter.prefix
        }
      }
    }
  }
}

/* CREATE THIS IN s3 module WHEN enable_replication = true
resource "aws_s3_bucket_replication_configuration" "source_to_replica" {
  count = var.enable_replication ? 1 : 0

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.bucket-version, aws_kms_key.bucket-key]

  role   = aws_iam_role.source[count.index].arn
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = ((var.replica_config != null ? (var.replica_config.rules != null) : false) ? [for r in var.replica_config.rules : {
      rule_id       = r.rule_id
      filters       = r.filters
      status        = r.status
      storage_class = r.storage_class
    }] : [])
    content {
      id = rule.value.rule_id
      status = rule.value.status
      priority = index(var.replica_config.rules, rule.value)

      delete_marker_replication {
        status = "Enabled"
      }

      source_selection_criteria {
        replica_modifications {
          status = "Enabled"
        }
        sse_kms_encrypted_objects {
          status = "Enabled"
        }
      }

      destination {
        bucket        = aws_s3_bucket.replica[count.index].arn
        storage_class = rule.value.storage_class
        encryption_configuration {
          replica_kms_key_id = aws_kms_key.replica[count.index].arn
        }
      }

      dynamic "filter" {
        for_each = [for f in rule.value.filters : {
          thefilter = f
        }]
        content {
          prefix = filter.value.thefilter.prefix
        }
      }
    }
  }
}
*/



