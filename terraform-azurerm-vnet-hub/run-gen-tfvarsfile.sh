#!/bin/bash

# Helper script for gen-tfvarsfile.sh

./gen-tfvarsfile.sh \
  -g "rd-vdc-eastus-dev-rg" \
  -l "eastus" \
  -t "{ costcenter = \"10177772\", division = \"US-CS-Heathcare-COGS\", group = \"SOUTHEAST\" }" \
  -v "rd-vdc-eastus-dev-hub-vnet" \
  -a "10.0.0.0/16" \
  -s "{ DefaultSubnet = \"10.0.0.0/24\", AzureBastionSubnet = \"10.0.1.0/27\" , GatewaySubnet = \"10.0.255.0/27\" }" \
  -i "Standard" \
  -r "LRS" \
  -o "4e04cdb4-0f6f-45b5-b115-90b742b19f12" \
  -d "72f988bf-86f1-41af-91ab-2d7cd011db47" \
  -h "rdvdceastusdevsig" \
  -b "rdvdceastusdevbh"
