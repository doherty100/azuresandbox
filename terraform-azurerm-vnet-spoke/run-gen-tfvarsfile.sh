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
  -g "rd-vdc-eastus-dev-rg"\
  -l "eastus"\
  -t "{ costcenter = \"10177772\", division = \"US-CS-Heathcare-COGS\", group = \"NORTHEAST\" }"\
  -v "rd-vdc-eastus-dev-vnet-spoke-winvm"\
  -a "10.1.0.0/16"\
  -s "{ DefaultSubnet = \"10.1.0.0/24\", AzureBastionSubnet = \"10.1.1.0/27\" }"\
  -i "/subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rd-vdc-eastus-dev-rg/providers/Microsoft.Network/virtualNetworks/rd-vdc-eastus-dev-hub-vnet"\
  -n "rd-vdc-eastus-dev-hub-vnet"\
  -b "rdvdceastusdevbh02"

