#!/bin/bash

# Helper script for gentfvarsfile.sh
# -g RESOURCE_GROUP_NAME
# -l LOCATION
# -t TAGS
# -n VM_NAME
# -s VM_IMAGE_SKU
# -z VM_SIZE
# -i SUBNET_ID
# -w LOG_ANALYTICS_WORKSPACE_ID

./gentfvarsfile.sh \
  -g "MyResourceGroupName" \
  -l "MyAzureRegion" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }" \
  -n "MyVmName" \
  -s "2019-Datacenter-smalldisk" \
  -z "Standard_B2ms" \
  -i "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroupName/providers/Microsoft.Network/virtualNetworks/MySpokeVnetName/subnets/DefaultSubnet" \
  -w "00000000-0000-0000-0000-000000000000"
