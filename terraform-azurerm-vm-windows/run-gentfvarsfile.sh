#!/bin/bash

# Helper script for gentfvarsfile.sh

./gentfvarsfile.sh \
  -g "rd-vdc-eastus2-dev-rg" \
  -l "eastus2" \
  -t "{ costcenter = \"10177772\", division = \"US-CS-Heathcare-COGS\", group = \"SOUTHEAST\" }" \
  -n "winmontest01" \
  -s "2019-Datacenter-smalldisk" \
  -z "Standard_B2ms" \
  -i "/subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rd-vdc-eastus2-dev-rg/providers/Microsoft.Network/virtualNetworks/rd-vdc-eastus2-dev-spokewin-vnet/subnets/default" \
  -w "4413b97d-028d-490a-a1e5-c47b98b5a2ec"
