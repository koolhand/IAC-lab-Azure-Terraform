# Terraform Azure lab for AD - working notes

## Prep

### References

- [Microsoft - Terraform on Azure documentation](https://docs.microsoft.com/en-us/azure/developer/terraform/)
- [Terraform documentation - Get Started - Azure](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)

### Install Terraform

I opted to run Terraform direct from Windows not WSL, so ```choco.exe install terraform``` is easiest. (see [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli) docs)

## What to create

###  Simple lab
- single domain controller
- public IP locked to you
- install RSAT
- create some OUs
- create some admin groups
- create some user groups
- create some GPOs
- set some suitable permissions

### stretch

- GPOs
  - create
  - load in Microsoft baseline GPOs
  - apply policy to non-domain-joined
- domain controller
  - in different availability zone
  - in different region
  - number of DCs as variable
- domain controller core, remote desktop server with RSAT
- passwords in Azure Key Vault
- better remote access protection
  - bastion
  - or VPN
  - or RD gateway

### long stretch

- cloud providers abstraction
   - can you wrap server parameters around Azure vs AWS vs libvirt vs vSphere
