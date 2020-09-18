/**
 * # Tiered Storage for AWS
 *
 * This terraform module creates the needed s3 bucket
 * and IAM policies, plus role creation/attachment
 * that is needed for storage offloading in Pulsar.
 *
 * This bucket also enables bucket encrpytion by default
 *
 * See the parameters for full details but here is an example usage:
 *
 * ```
 * module "tiered_storage" {
 *   source = "streamnative/managed-cloud/aws//tiered_storage"
 *   bucket_name = "myorg-pulsar-offload-us-east-1"
 *   bucket_tags = {
 *     Project = "MyApp"
 *     Environment = "Prod"
 *   }
 *   # attach policy to existing role
 *   existing_role_name = "my-pulsar-cluster-role"
 * }
 * ```
 */
terraform {
  required_providers {
    aws = {
      version = ">= 2.70.0"
      source  = "hashicorp/aws"
    }
  }
}

variable "bucket_name" {
  description = "the name of the s3 bucket"
}

variable "bucket_tags" {
  description = "the tags to add to the bucket"
  default     = {}
  type        = map(string)
}

variable "existing_role_name" {
  description = "an optional existing role name, if not provided, a role with role_name will be created"
  default     = ""
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


module "role" {
  source             = "../base_role"
  existing_role_name = var.existing_role_name
  role_name          = var.role_name

  role_policy_name = "pulsar_offload"
  role_policy      = data.aws_iam_policy_document.pulsar_offload.json

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

output "role_name" {
  value       = module.role.role_name
  description = "the name of the role"
}

output "role_arn" {
  value       = module.role.role_arn
  description = "the arn of the role"
}

output "s3_bucket" {
  value       = aws_s3_bucket.pulsar_offload.bucket
  description = "the name of the bucket used for offloading"
}
output "s3_bucket_arn" {
  value       = aws_s3_bucket.pulsar_offload.arn
  description = "the arn of the bucket used for offloading"
}
