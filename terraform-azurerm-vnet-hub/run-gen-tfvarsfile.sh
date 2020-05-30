#!/bin/bash

# Helper script for gen-tfvarsfile.sh
# -g RESOURCE_GROUP_NAME
# -l LOCATION
# -v VNET_NAME
# -a VNET_ADDRESS_SPACE
# -s SUBNETS
# -r STORAGE_REPLICATION_TYPE
# -q STORAGE_SHARE_QUOTA_GB
# -o KEY_VAULT_ADMIN_OBJECT_ID
# -d AAD_TENANT_ID
# -t TAGS

./gen-tfvarsfile.sh \
  -g "rg-vdc-nonprod-001" \
  -l "eastus" \
  -v "vnet-hub-001" \
  -a "10.1.0.0/16" \
  -s "{ snet-default-001 = \"10.1.0.0/24\", AzureBastionSubnet = \"10.1.1.0/27\", snet-storage-private-endpoints-001 = \"10.1.2.0/24\" }" \
  -r "LRS" \
  -q "1024" \
  -o "00000000-0000-0000-0000-000000000000" \
  -d "00000000-0000-0000-0000-000000000000" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
  