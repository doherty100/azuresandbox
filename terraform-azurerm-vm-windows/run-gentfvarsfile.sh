#!/bin/bash

# Helper script for gentfvarsfile.sh

./gentfvarsfile.sh \
  -n "winmontest01" \
  -s "2019-Datacenter-smalldisk" \
  -t "Standard_B2ms" \
  -g "rd-vdc-eastus2-dev-rg" \
  -l "eastus2" \
  -i "/subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rd-vdc-eastus2-dev-rg/providers/Microsoft.Network/virtualNetworks/rd-vdc-eastus2-dev-hub-vnet/subnets/default" \
  -w "08b493c3-2c39-4275-953e-f444d0a27d4d"