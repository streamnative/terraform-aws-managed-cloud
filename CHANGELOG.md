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
