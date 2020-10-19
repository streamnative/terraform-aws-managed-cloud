## v0.3.2 - Add (one more) policy for lookups

* Adds `route53:ListTagsForResource` to the bootstrap policy

## v0.3.1 - Add additional route53 policy for lookups

* Adds `route53:ListHostedZones` to the bootstrap policy

## v0.3.0 - Add module for ACM certs, update bootstrap policy to support it

* Adds the `acm_certificate` module
* Add support to `bootstrap_policy` to hav relevant ACM and route53 permissions

## v0.2.1 - Fix bootstrap_policy and dynamo modules

* The bootstrap_policy module was missing a number of IAM permissions
* The dynamo policy would always have changes for the read/write capacity

## v0.2.0 - Add modules for role/policies for streamnative management

* Adds the bootstrap_policy and bootstrap_role modules that
  used for initial provisioning of AWS resources
* Adds the management_policy and management_role modules
  that are used for pulsar cluster provisioning and management
* Reworks the tiered_storage and vault_resources modules to optionally not
  need to create policies instead of only attach

## v0.1.0 - Initial Release

* Reworks this repo to support terraform module registry
* Support for creating tiered_storage
* Support for creating vault_resources
