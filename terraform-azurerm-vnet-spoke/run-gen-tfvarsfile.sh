#!/bin/bash
# -v VNET_NAME
# -a VNET_ADDRESS_SPACE
# -s SUBNETS
# -t TAGS

# Helper script for gen-tfvarsfile.sh

./gen-tfvarsfile.sh \
  -v "vnet-spoke-001"\
  -a "10.2.0.0/16"\
  -s "{ snet-default-002 = \"10.2.0.0/24\", AzureBastionSubnet = \"10.2.1.0/27\", snet-db-001 = \"10.2.1.32/27\", snet-app-001 = \"10.2.1.64/27\" }"\
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
  