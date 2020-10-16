/**
 * # ACM Certificate for AWS
 *
 * This terraform module creates the needed ACM certificate
 * that is needed for provisioning the load balancers used
 * for Pulsar cluster.
 *
 * See the parameters for full details but there is an example usage:
 *
 * ```
 * module "acm_certificate" {
 *   source = "streamnative/managed-cloud/aws//acm_certificate"
 *   domain_name = "*.pulsar.example.com"
 *   hosted_zone_id = "my-hosted-zone-id"
 *   tags = {
 *     Enviroment: "Production"
 *   }
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

variable "domain_name" {
  description = "A domain name for which the certificate should be issued. It is recommended to use a wildcard domain name. So you just need one ACM certficate for both the admin and data service endpoints. For example, you can use `*.pulsar.example` as the domain name to provision the certificate."
}

variable "additional_domain_names" {
  description = "Set of domains that should be SANs in the issued certificate."
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  type        = string
  description = "Route 53 Zone ID for DNS validation records"
}

variable "validation_record_ttl" {
  default     = 60
  type        = number
  description = "Route 53 time-to-live for validation records"
}

variable "allow_validation_record_overwrite" {
  default     = true
  type        = bool
  description = "Allow Route 53 record creation to overwrite existing records"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the ACM certificate"
}

resource "aws_acm_certificate" "pulsar_certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = var.additional_domain_names
  validation_method         = "DNS"
  tags = merge(
    {
      Name        = replace(var.domain_name, "*", "_")
    },
    var.tags,
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "pulsar_certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.pulsar_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name            = each.value.name
  type            = each.value.type
  zone_id         = var.hosted_zone_id
  records         = [each.value.record]
  ttl             = var.validation_record_ttl
  allow_overwrite = var.allow_validation_record_overwrite
}

resource "aws_acm_certificate_validation" "pulsar_acm_validation" {
  certificate_arn = aws_acm_certificate.pulsar_certificate.arn

  validation_record_fqdns = [for record in aws_route53_record.pulsar_certificate_validation : record.fqdn]
}

output "arn" {
  value = aws_acm_certificate_validation.pulsar_acm_validation.certificate_arn
}
