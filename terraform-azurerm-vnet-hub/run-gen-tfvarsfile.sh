#!/bin/bash

# Helper script for gen-tfvarsfile.sh

./gen-tfvarsfile.sh \
  -g "rd-vdc-eastus2-dev-rg" \
  -l "eastus2" \
  -t "{ costcenter = \"10177772\", division = \"US-CS-Heathcare-COGS\", group = \"SOUTHEAST\" }" \
  -v "rd-vdc-eastus2-dev-hub-vnet" \
  -a "10.0.0.0/16" \
  -s "[ { name = \"default\", address_prefix = \"10.0.0.0/24\" }, { name = \"GatewaySubnet\", address_prefix = \"10.0.255.0/27\" } ]" \
  -i "Standard" \
  -r "LRS" \
  -k "rd-vdc-eastus2-dev-kv" \
  -d "72f988bf-86f1-41af-91ab-2d7cd011db47" \
  -h "rdvdceastus2devsig"
