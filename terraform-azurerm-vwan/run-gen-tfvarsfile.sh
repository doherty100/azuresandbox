#!/bin/bash

# Helper script for gen-tfvarsfile.sh
# -g RESOURCE_GROUP_NAME
# -l LOCATION
# -t TAGS
# -v VWAN_NAME
# -h VWAN_HUB_NAME
# -a VWAN_HUB_ADDRESS_PREFIX
# -r REMOTE_VIRTUAL_NETWORK_IDS

./gen-tfvarsfile.sh \
  -g "MyResourceGroupName" \
  -l "MyAzureRegion" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }" \
  -v "MyVwanName" \
  -h "MyVwanHubName" \
  -a "10.3.0.0/16" \
  -r "{ MyHubVNetId = \"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroupName/providers/Microsoft.Network/virtualNetworks/MyHubVNetName\", MySpokeVnetId = \"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroupName/providers/Microsoft.Network/virtualNetworks/MySpokeVNetName\" }"
