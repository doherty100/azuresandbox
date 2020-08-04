#!/bin/bash
# -v VNET_NAME
# -a VNET_ADDRESS_SPACE
# -s SUBNETS
# -t TAGS

# Helper script for gen-tfvarsfile.sh

./gen-tfvarsfile.sh \
  -v "vnet-spoke-001"\
  -a "10.2.0.0/16"\
  -s "{ default = [\"snet-default-002\", \"10.2.0.0/24\"], AzureBastionSubnet = [ \"AzureBastionSubnet\", \"10.2.1.0/27\"], database = [\"snet-db-001\", \"10.2.1.32/27\"], application = [\"snet-app-001\", \"10.2.1.64/27\" ] }"\
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
  