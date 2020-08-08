#!/bin/bash
# -v VNET_NAME
# -a VNET_ADDRESS_SPACE
# -s SUBNETS
# -t TAGS

# Helper script for gen-tfvarsfile.sh

./gen-tfvarsfile.sh \
  -v "vnet-spoke-001"\
  -a "10.2.0.0/16"\
  -s "{ default  = { name = \"snet-default-002\", address_prefix = \"10.2.0.0/24\", enforce_private_link_endpoint_network_policies = false }, AzureBastionSubnet = { name = \"AzureBastionSubnet\", address_prefix = \"10.2.1.0/27\", enforce_private_link_endpoint_network_policies = false }, database = {name = \"snet-db-001\", address_prefix = \"10.2.1.32/27\", enforce_private_link_endpoint_network_policies = false }, application = { name = \"snet-app-001\", address_prefix = \"10.2.1.64/27\", enforce_private_link_endpoint_network_policies = false } }"\
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
  