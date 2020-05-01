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

./gen-tfvarsfile.sh \
  -g "MyResourceGroupName" \
  -l "MyAzureRegion" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }" \
  -v "MyHubVnetName" \
  -a "10.1.0.0/16" \
  -s "{ DefaultSubnet = \"10.1.0.0/24\", AzureBastionSubnet = \"10.1.1.0/27\" }" \
  -i "Standard" \
  -r "LRS" \
  -o "00000000-0000-0000-0000-000000000000" \
  -d "00000000-0000-0000-0000-000000000000" \
  -h "MySharedImageGalleryName" \
  -b "MyHubVnetBastionHostName"
