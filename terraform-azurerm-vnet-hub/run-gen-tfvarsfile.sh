#!/bin/bash

# Helper script for gen-tfvarsfile.sh
# -g RESOURCE_GROUP_NAME
# -l LOCATION
# -v VNET_NAME
# -a VNET_ADDRESS_SPACE
# -s SUBNETS
# -q STORAGE_SHARE_QUOTA_GB
# -d AAD_TENANT_ID
# -o KEY_VAULT_ADMIN_OBJECT_ID
# -t TAGS

./gen-tfvarsfile.sh \
  -g "rg-vdc-nonprod-001" \
  -l "eastus" \
  -v "vnet-hub-001" \
  -a "10.1.0.0/16" \
  -s "{ default = { name = \"snet-default-001\", address_prefix = \"10.1.0.0/24\", enforce_private_link_endpoint_network_policies = false }, AzureBastionSubnet = { name = \"AzureBastionSubnet\", address_prefix = \"10.1.1.0/27\", enforce_private_link_endpoint_network_policies = false }, private_endpoints = { name = \"snet-storage-private-endpoints-001\", address_prefix = \"10.1.2.0/24\", enforce_private_link_endpoint_network_policies = true } }" \
  -q "1024" \
  -d "00000000-0000-0000-0000-000000000000" \
  -o "00000000-0000-0000-0000-000000000000" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
  