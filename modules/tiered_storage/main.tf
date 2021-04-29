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
  description = "an optional existing role name to attach the policy to"
  default     = ""
}

variable "new_role_name" {
  description = "an optional role name to create and attach the policy to"
  default     = ""
}

variable "policy_name" {
  description = "the name of the policy"
  default     = "pulsar_offload"
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
  source             = "../base_policy_role"
  existing_role_name = var.existing_role_name
  new_role_name      = var.new_role_name

  policy_name = var.policy_name
  role_policy = data.aws_iam_policy_document.pulsar_offload.json

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

output "role_names" {
  value       = module.role.role_names
  description = "the names of the roles"
}

output "role_arn" {
  value       = module.role.role_arns
  description = "the arns of the roles"
}

output "policy_name" {
  value = module.role.policy_name
}

output "policy_arn" {
  value = module.role.policy_arn
}

output "policy_document" {
  value = data.aws_iam_policy_document.pulsar_offload.json
}

output "s3_bucket" {
  value       = aws_s3_bucket.pulsar_offload.bucket
  description = "the name of the bucket used for offloading"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.pulsar_offload.arn
  description = "the arn of the bucket used for offloading"
}
