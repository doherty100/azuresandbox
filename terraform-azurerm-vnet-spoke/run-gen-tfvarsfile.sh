#!/bin/bash
# -g RESOURCE_GROUP_NAME
# -l LOCATION
# -t TAGS
# -v VNET_NAME
# -a VNET_ADDRESS_SPACE
# -s SUBNETS
# -i REMOTE_VIRTUAL_NETWORK_ID
# -n REMOTE_VIRTUAL_NETWORK_NAME
# -b BASTION_HOST_NAME

# Helper script for gen-tfvarsfile.sh

./gen-tfvarsfile.sh \
  -g "MyResourceGroupName"\
  -l "MyAzureRegion"\
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }" \
  -v "MySpokeVnetName"\
  -a "10.1.0.0/16"\
  -s "{ DefaultSubnet = \"10.1.0.0/24\", AzureBastionSubnet = \"10.1.1.0/27\" }"\
  -i "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroupName/providers/Microsoft.Network/virtualNetworks/MyHubVnetName"\
  -n "MyHubVnetName"\
  -b "MySpokeVnetBastionHostName"


