# Azure quick start configuration: terraform-azurerm-vm-adds  

## Overview

This quick start implements [Active Directory Domain Services](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) which is used in other quick starts to domain join Windows Server virtual machines and other resources like Azure Files. A single domain controller is created in the shared services virtual network with a configurable domain name which is populated with test users, organizational units and groups.

The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~10 minutes
Smoke testing | ~ 15 minutes
De-provisioning | ~ 5 minutes

Note: As detailed in [Deploy AD DS in an Azure virtual network](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/identity/adds-extend-domain) describes, deploying two redundant domain controllers in an Availability Set is recommended for better resiliency.

## Getting started

This section describes how to provision this quick start using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Resource index

## Smoke testing

*

## Next steps
