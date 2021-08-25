# Azure quick start configuration: terraform-azurerm-sql  

## Overview

This quick start implements an Azure SQL Database for testing web applications and running database benchmarks like [HammerDB](https://www.hammerdb.com/) using a [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/) approach. The following quick starts must be deployed first before starting:

* [terraform-azurerm-vnet-shared](../terraform-azurerm-vnet-shared)
* [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke)
* [terraform-azurerm-vm-sql](../terraform-azurerm-vm-sql)

Activity | Estimated time required
--- | ---
Pre-configuration | ~10 minutes
Provisioning | ~5 minutes
Smoke testing | ~ 15 minutes
De-provisioning | ~ 5 minutes

## Getting started

This section describes how to provision this quick start using default settings.

* Run `./bootstrap.sh` using the default settings or your own custom settings.
* Run `terraform init` and note the version of the *azurerm* provider installed.
* Run `terraform validate` to check the syntax of the configuration.
* Run `terraform plan` and review the plan output.
* Run `terraform apply` to apply the configuration.

## Resource index

This section provides an index of the 8 resources included in this quick start.

### Azure SQL Database logical server

---

Azure SQL Database [logical server](https://docs.microsoft.com/en-us/azure/azure-sql/database/logical-servers) with pre-configured administrator credentials using key vault. An automatically generated name is assigned following the grep format "sql-\[a-z0-9\]\{16\}-01".

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
sql_server_01_fqdn | Output | string | Local | sql-7d967bca17b9b938-01.database.windows.net
sql_server_01_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Sql/servers/sql-7d967bca17b9b938-01
sql_server_01_name | Output | string | Local |  sql-7d967bca17b9b938-01

#### Private endpoint

[Private endpoint](https://docs.microsoft.com/en-us/azure/azure-sql/database/private-endpoint-overview) with an automatically generated random name following the grep format "pend-\[a-z0-9\]\{16\}-02" for use with the Azure SQL Database logical server described earlier.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
sql_server_01_private_endpoint_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/privateEndpoints/pend-e94eac79b564aa0a-02
sql_server_01_private_endpoint_name | Output | string | Local | pend-e94eac79b564aa0a-02
sql_server_01_private_endpoint_prvip | Output | string | Local | 10.2.1.100

#### Private DNS zone

Shared [private DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) *privatelink.database.windows.net* for use with the Azure SQL Database logical server private endpoint described previously. Note this resource has a dependency on [terraform-azurerm-vnet-spoke](../terraform-azurerm-vnet-spoke).

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
private_dns_zone_2_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net
private_dns_zone_2_name | Output | string | Global | privatelink.database.windows.net

##### Private DNS zone A record

A DNS A record is created in the private DNS zone with a default ttl of 300. The name of the A record is set to the name of the Azure SQL Database logical server.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
private_dns_a_record_2_id | Output | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net/A/sql-7d967bca17b9b938-01
private_dns_a_record_2_name | Output | string | Local | sql-7d967bca17b9b938-01

##### Private DNS zone virtual network link

A [virtual network link](https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links) to the spoke virtual network is established with the private DNS zone *privatelink.database.windows.net* for use with the Azure SQL Database logical server private endpoint resource.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
vnet_id | Input | string | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/virtualNetworks/vnet-spoke-01
vnet_name | Input | string | Local | vnet-spoke-01
virtual_network_link_vnet_spoke_01_id | Output | string | Local | /subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net/virtualNetworkLinks/pdnslnk-vnet-spoke-01-02
virtual_network_link_vnet_shared_01_name | Output | string | Local | pdnslnk-vnet-spoke-01-02

#### Azure SQL Database

[Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview) for testing web applications and running database benchmarks like [HammerDB](https://www.hammerdb.com/) using a [PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/) approach. The database is associated with the Azure SQL Database logical server.

Variable | In/Out | Type | Scope | Sample
--- | --- | --- | --- | ---
sql_database_name | Input | String | Local | sqldb-benchmarktest-01
sql_database_01_id | Output | String | Local | /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vdc-nonprod-01/providers/Microsoft.Sql/servers/sql-7d967bca17b9b938-01/databases/sqldb-benchmarktest-01
sql_database_01_name | Output | String | Local | sqldb-benchmarktest-01

## Smoke testing

* Explore newly provisioned resources using the Azure portal.
  * Review the 2 secrets that were created in the shared key vault.
  * Review the spoke virtual network and the subnet used for private endpoints.
  * Review the Azure SQL Database logical server
    * Make a note of the server name fqdn for use later, e.g. *sql-xxxxxxxxxxxxxxxx-01.database.windows.net*
    * Review the private endpoint connection and note that it was auto approved
    * Review the Azure SQL Database
  * Review the private DNS zone *privatelink.database.windows.net*
    * Review the A record that resolves DNS queries for the Azure SQL Database logical server to a private ip address
* Connect to the database server virtual machine from [terraform-azurerm-vm-sql](../terraform-azurerm-vm-sql) machine in the Azure portal using bastion and log in with the *adminuser* and *adminpassword* defined previously.
  * Confirm DNS queries resolve to the Azure SQL Database logical server private endpoint.
    * Launch Windows PowerShell ISE
    * Run `Resolve-DnsName sql-xxxxxxxxxxxxxxxx-01.database.windows.net` from the Windows PowerShell ISE console.  
    * Verify the the *IP4Address* returned is consistent with the address prefix used for the *snet-storage-private-endpoints-02* subnet in the spoke virtual network. This name resolution is accomplished using the private DNS zone.
  * Connect to Azure SQL Database using the private endpoint
    * Launch SQL Server Management Studio
    * Connect using the following properties:
      * Server type: Database Engine
      * Server name: sql-xxxxxxxxxxxxxxxx-01.database.windows.net
      * Authentication: SQL Server Authentication
        * Login: The *adminuser* credentials used when provisioning the  Azure SQL Database logical server.
        * Password: The *adminpassword* credentials used when provisioning the Azure SQL Database logical server.
      * Confirm you can see the Azure SQL Database provisioned earlier.

## Next steps

Move on to the next quick start [terraform-azurerm-vwan](../terraform-azurerm-vwan).
