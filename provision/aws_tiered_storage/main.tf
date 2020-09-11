/**
 * # Tiered Storage for AWS
 *
 * This terraform module creates the needed s3 bucket
 * and IAM policies, plus role creation/attachment
 * that is needed for storage offloading in Pulsar.
 *
 * See the parame
 *
 */
provider "aws" {
}

variable "bucket_name" {
  description = "the name of the s3 bucket"
}

variable "bucket_tags" {
  description = "the tags to add to the bucket"
  default     = []
}

variable "existing_role_name" {
  description = "an optional existing role name, if not provided, a role with role_name will be created"
  default = ""
}

variable "role_name" {
  description = "the name of the role to be created (if existing_role_name is not provided)"
  default     = "pulsar-offload-role"
}

resource "aws_s3_bucket" "pulsar_offload" {
  bucket = var.bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = var.bucket_tags
}

data "aws_iam_policy_document" "pulsar_offload" {

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject*",
      "s3:GetObject*",
      "s3:PutObject*",
      "s3:List*",
    ]

    resources = [
      aws_s3_bucket.pulsar_offload.arn,
      "${aws_s3_bucket.pulsar_offload.arn}/*",
    ]
  }
}


resource "aws_iam_instance_profile" "pulsar_offload" {
  count = var.existing_role_name != "" ? 0 : 1
  name  = element(aws_iam_role.pulsar_offload.*.name, 0)
  role  = element(aws_iam_role.pulsar_offload.*.name, 0)
}

resource "aws_iam_role" "pulsar_offload" {
  count              = var.existing_role_name != "" ? 0 : 1
  name               = var.existing_role_name
  assume_role_policy = data.aws_iam_policy_document.pulsar_offload_assume.json
}

resource "aws_iam_role_policy" "pulsar_offload" {
  name = "${var.bucket_name}-pulsar_offload"
  role = coalesce(var.existing_role_name, element(aws_iam_role.pulsar_offload.*.name, 0))

  policy = data.aws_iam_policy_document.pulsar_offload.json
}

data "aws_iam_policy_document" "pulsar_offload_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_role" "existing" {
  count = var.existing_role_name != "" ? 1 : 0
  name  = var.existing_role_name
}


output "role_name" {
  value       = coalesce(var.existing_role_name, element(aws_iam_role.pulsar_offload.*.name, 0))
  description = "the name of the role"
}

output "role_arn" {
  value       = coalesce(element(data.aws_iam_role.existing.*.arn, 0), element(aws_iam_role.pulsar_offload.*.arn, 0))
  description = "the arn of the role"
}

output "s3_bucket" {
  value = aws_s3_bucket.pulsar_offload.bucket
  description = "the name of the bucket used for offloading"
}
output "s3_bucket_arn" {
  value = aws_s3_bucket.pulsar_offload.arn
  description = "the arn of the bucket used for offloading"
}
