# ACM Certificate for AWS

This terraform module creates the needed ACM certificate  
that is needed for provisioning the load balancers used  
for Pulsar cluster.

See the parameters for full details but there is an example usage:

```
module "acm_certificate" {
  source = "streamnative/managed-cloud/aws//acm_certificate"
  domain_name = "*.pulsar.example.com"
  hosted_zone_id = "my-hosted-zone-id"
  tags = {
    Enviroment: "Production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| aws | >= 2.70.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_domain\_names | Set of domains that should be SANs in the issued certificate. | `list(string)` | `[]` | no |
| allow\_validation\_record\_overwrite | Allow Route 53 record creation to overwrite existing records | `bool` | `true` | no |
| domain\_name | A domain name for which the certificate should be issued. It is recommended to use a wildcard domain name. So you just need one ACM certficate for both the admin and data service endpoints. For example, you can use `*.pulsar.example` as the domain name to provision the certificate. | `any` | n/a | yes |
| hosted\_zone\_id | Route 53 Zone ID for DNS validation records | `string` | n/a | yes |
| tags | Extra tags to attach to the ACM certificate | `map(string)` | `{}` | no |
| validation\_record\_ttl | Route 53 time-to-live for validation records | `number` | `60` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | n/a |

