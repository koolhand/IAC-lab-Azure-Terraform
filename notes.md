# Terraform Azure lab for AD - working notes

## Prep

### References

- [Microsoft - Terraform on Azure documentation](https://docs.microsoft.com/en-us/azure/developer/terraform/)
- [Terraform documentation - Get Started - Azure](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)

### Install Terraform and Azure-CLI

I opted to run Terraform direct from Windows not WSL, so chocolatey is easiest. (see Terraform docs - [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli))

Then Azure-CLI ```az``` is the prerequisite that Terraform uses - not the ```Az-*``` PowerShell modules, so chocolatey again for ```az```. (see Terraform docs - [Build Infrastructure - Azure Example](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build))


```PowerShell
choco.exe install terraform
choco.exe install azure-cli
```

### Authenticate to Azure, create service principal to use

```PowerShell
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"
$Env:ARM_CLIENT_ID = "<APPID_VALUE>"
$Env:ARM_CLIENT_SECRET = "<PASSWORD_VALUE>"
$Env:ARM_SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
$Env:ARM_TENANT_ID = "<TENANT_VALUE>"
```

### start creating

Create ```main.tf```, cop from [Initialize your Terraform configuration](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build#initialize-your-terraform-configuration)

Then

```PowerShell
terraform init
terraform fmt
terraform validate
```

then if successful

```PowerShell
terraform apply
terraform show
terraform state list
```

## What to create

###  Simple lab

- [ ] resource group with subnet, NSG, VM connected, rules allowing remote admin
- [ ] public IP, NSG rules locked to your private IP
- [ ] provision software on the VM:
  - [ ] single domain controller
  - [ ] install RSAT
- [ ] AD configuration
  - [ ] create some OUs
  - [ ] create some admin groups
  - [ ] create some user groups
  - [ ] create some GPOs
  - [ ] set some suitable permissions

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
