#!/bin/bash

# Helper script for gentfvarsfile.sh

./gentfvarsfile.sh \
  -n "winmontest01" \
  -s "2019-Datacenter-smalldisk" \
  -t "Standard_B2ms" \
  -g "rd-vdc-eastus2-dev-rg" \
  -l "eastus2" \
  -i "/subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rd-vdc-eastus2-dev-rg/providers/Microsoft.Network/virtualNetworks/rd-vdc-eastus2-dev-spokewin-vnet/subnets/default" \
  -w "4413b97d-028d-490a-a1e5-c47b98b5a2ec"