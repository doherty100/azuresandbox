# Azure quick start configuration: terraform-azurerm-sql  

## Overview

This quick start implements an Azure SQL Database for testing web applications and running database benchmarks like [HammerDB](https://www.hammerdb.com/) using a [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/) approach. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
* [terraform-azurerm-bench-windows](../terraform-azurerm-bench-windows)

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~5 minutes
Smoke testing | ~ 15 minutes
De-provisioning | ~ 5 minutes

### Getting started with default settings

This section describes how to provision this quick start using default settings.

* Create required secrets in shared key vault
  * Define values to be used for the following secrets:
    * *adminuser*: the admin user name to use when provisioning the new Azure SQL Database logical server.
    * *adminpassword*: the admin password to use when provisioning the new Azure SQL Database logical server. Note that the password must meet SQL Server [Password Complexity](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver15#password-complexity) requirements. Be sure to use the escape character "\\" before any [metacharacters](https://www.gnu.org/software/bash/manual/bash.html#Definitions) in your password.
  * Run `./pre-deploy.sh -u "MyAdminUserName" -p "MyStrongAdminPassword"` using the values defined previously.
* Run `./run-gen-tfvarsfile.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

### Getting started with custom settings

This section describes how to provision this quick start using custom settings. Refer to [Perform custom quick start deployment](https://github.com/doherty100/azurequickstarts#perform-custom-quick-start-deployment) for more details.

* Create required secrets in shared key vault
  * Define values to be used for the following secrets:
    * *adminuser*: the admin user name to use when provisioning the new Azure SQL Database logical server.
    * *adminpassword*: the admin password to use when provisioning the new Azure SQL Database logical server. Note that the password must meet SQL Server [Password Complexity](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver15#password-complexity) requirements. Be sure to use the escape character "\\" before any [metacharacters](https://www.gnu.org/software/bash/manual/bash.html#Definitions) in your password.
  * Run `./pre-deploy.sh -u "MyAdminUserName" -p "MyStrongAdminPassword"` using the values defined previously.
* Run `cp run-gen-tfvarsfile.sh run-gen-tfvarsfile-private.sh` to ensure custom settings don't get clobbered in the future.
* Edit `run-gen-tfvarsfile-private.sh`.
  * -d: Change to a different *sql_database_name* if desired.
  * -t: Change to a different *tags* map if desired.
  * Save changes.
* Run `./run-gen-tfvarsfile-private.sh` to generate *terraform.tfvars*.  
* Run `terraform init`.
* Run `terraform apply`.

## Resource index

This section provides an index of the 2 resources included in this quick start.

### Azure SQL Database logical server

---

Azure SQL Database [logical server](https://docs.microsoft.com/en-us/azure/azure-sql/database/logical-servers) with pre-configured administrator credentials using key vault. An automatically generated name is assigned following the grep format "sql-\[a-z0-9\]\{16\}-001".

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
tags | Input | string | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
sql_server_01_fqdn | Output | string | Local | sql-7d967bca17b9b938-001.database.windows.net
sql_server_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Sql/servers/sql-7d967bca17b9b938-001
sql_server_01_name | Output | string | Local |  sql-7d967bca17b9b938-001

#### Private endpoint

[Private endpoint](https://docs.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview) with an automatically generated random name following the grep format "pend-\[a-z0-9\]\{16\}-002" for use with the Azure SQL Database logical server described earlier.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
sql_server_01_private_endpoint_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/privateEndpoints/pend-e94eac79b564aa0a-002
sql_server_01_private_endpoint_name | Output | string | Local | pend-e94eac79b564aa0a-002
sql_server_01_private_endpoint_prvip | Output | string | Local | 10.2.1.100

#### Private DNS zone

Shared [private DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) *privatelink.database.windows.net* for use with the Azure SQL Database logical server private endpoint described previously. Note this resource has a dependency on [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke).

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
private_dns_zone_2_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net
private_dns_zone_2_name | Output | string | Global | privatelink.database.windows.net

##### Private DNS zone A record

A DNS A record is created in the private DNS zone with a default ttl of 300. The name of the A record is set to the name of the Azure SQL Database logical server.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
private_dns_a_record_2_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net/A/sql-7d967bca17b9b938-001
private_dns_a_record_2_name | Output | string | Local | sql-7d967bca17b9b938-001

##### Private DNS zone virtual network link

A [virtual network link](https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links) to the spoke virtual network is established with the private DNS zone *privatelink.database.windows.net* for use with the Azure SQL Database logical server private endpoint resource.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
virtual_network_link_vnet_spoke_01_id | Output | string | Local | /subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net/virtualNetworkLinks/pdnslnk-vnet-spoke-001-002
virtual_network_link_vnet_hub_01_name | Output | string | Local | pdnslnk-vnet-spoke-001-002

#### Azure SQL Database

[Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview) for testing web applications and running database benchmarks like [HammerDB](https://www.hammerdb.com/) using a [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/) approach. The database is associated with the Azure SQL Database logical server.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
sql_database_name | Input | String | Local | sqldb-benchmarktest-01
tags | Input | string | Local | { costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }
sql_database_01_id | Output | String | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-001/providers/Microsoft.Sql/servers/sql-7d967bca17b9b938-001/databases/sqldb-benchmarktest-01
sql_database_01_name | Output | String | Local | sqldb-benchmarktest-01

## Smoke testing

* Explore newly provisioned resources using the Azure portal.
  * Review the 2 secrets that were created in the shared key vault.
  * Review the spoke virtual network and the subnet used for private endpoints.
  * Review the Azure SQL Database logical server
    * Make a note of the server name fqdn for use later, e.g. *sql-xxxxxxxxxxxxxxxx-001.database.windows.net*
    * Review the private endpoint connection and note that it was auto approved
    * Review the Azure SQL Database
  * Review the private DNS zone *privatelink.database.windows.net*
    * Review the A record that resolves DNS queries for the Azure SQL Database logical server to a private ip address
* Connect to the database server virtual machine from [terraform-azurerm-bench-windows](../terraform-azurerm-bench-windows) machine in the Azure portal using bastion and log in with the *adminuser* and *adminpassword* defined previously.
  * Confirm DNS queries resolve to the Azure SQL Database logical server private endpoint.
    * Launch Windows PowerShell ISE
    * Run `Resolve-DnsName sql-xxxxxxxxxxxxxxxx-001.database.windows.net` from the Windows PowerShell ISE console.  
    * Verify the the *IP4Address* returned is consistent with the address prefix used for the *snet-storage-private-endpoints-002* subnet in the spoke virtual network. This name resolution is accomplished using the private DNS zone.
  * Connect to Azure SQL Database using the private endpoint
    * Launch SQL Server Management Studio
    * Connect using the following properties:
      * Server type: Database Engine
      * Server name: sql-xxxxxxxxxxxxxxxx-001.database.windows.net
      * Authentication: SQL Server Authentication
        * Login: The *adminuser* credentials used when provisioning the  Azure SQL Database logical server.
        * Password: The *adminpassword* credentials used when provisioning the Azure SQL Database logical server.
      * Confirm you can see the Azure SQL Database provisioned earlier.

## Next steps

Move on to the next quick start [terraform-azurerm-vwan](../terraform-azurerm-vwan).
