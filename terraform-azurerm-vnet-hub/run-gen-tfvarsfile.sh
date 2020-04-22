#!/bin/bash

# Helper script for gen-tfvarsfile.sh
# -g RESOURCE_GROUP_NAME
# -l LOCATION
# -t TAGS
# -v VNET_NAME
# -a VNET_ADDRESS_SPACE
# -s SUBNETS
# -i STORAGE_ACCOUNT_TIER
# -r STORAGE_REPLICATION_TYPE
# -o KEY_VAULT_ADMIN_OBJECT_ID
# -d AAD_TENANT_ID
# -h SHARED_IMAGE_GALLERY_NAME
# -b BASTION_HOST_NAME
# -2 SECURITY_CENTER_SCOPE

./gen-tfvarsfile.sh \
  -g "rd-vdc-eastus-dev-rg" \
  -l "eastus" \
  -t "{ costcenter = \"10177772\", division = \"US-CS-Heathcare-COGS\", group = \"NORTHEAST\" }" \
  -v "rd-vdc-eastus-dev-hub-vnet" \
  -a "10.0.0.0/16" \
  -s "{ DefaultSubnet = \"10.0.0.0/24\", AzureBastionSubnet = \"10.0.1.0/27\" , GatewaySubnet = \"10.0.255.0/27\" }" \
  -i "Standard" \
  -r "LRS" \
  -o "4e04cdb4-0f6f-45b5-b115-90b742b19f12" \
  -d "72f988bf-86f1-41af-91ab-2d7cd011db47" \
  -h "rdvdceastusdevsig" \
  -b "rdvdceastusdevbh" \
  -w "/subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55"
