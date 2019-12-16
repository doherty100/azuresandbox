#!/bin/bash

# Helper script for gentfvarsfile.sh

./gentfvarsfile.sh \
  -g "rd-vdc-eastus-dev-rg" \
  -l "eastus" \
  -t "{ costcenter = \"10177772\", division = \"US-CS-Heathcare-COGS\", group = \"SOUTHEAST\" }" \
  -n "winmontest01" \
  -s "2019-Datacenter-smalldisk" \
  -z "Standard_B2ms" \
  -i "/subscriptions/f6d69ee2-34d5-4ca8-a143-7a2fc1aeca55/resourceGroups/rd-vdc-eastus-dev-rg/providers/Microsoft.Network/virtualNetworks/rd-vdc-eastus-dev-vnet-spoke-winvm/subnets/DefaultSubnet" \
  -w "f4030c5f-7bdb-4469-bbac-bbfa3249c689"
