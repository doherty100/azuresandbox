#!/bin/bash

# Helper script for gen-tfvarsfile.sh
# -g RESOURCE_GROUP_NAME
# -l LOCATION
# -t TAGS
# -v VWAN_NAME
# -h VWAN_HUB_NAME
# -a VWAN_HUB_ADDRESS_PREFIX
# -c VWAN_HUB_CONNECTION_NAME_1
# -r REMOTE_VIRTUAL_NETWORK_IDS

./gen-tfvarsfile.sh \
  -g "MyResourceGroupName" \
  -l "MyAzureRegion" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }" \
  -v "MyVwanName" \
  -h "MyVwanHubName" \
  -a "10.2.0.0/16" \
  -c "MyVwanHubConnectionName" \
  -r "{ MyHubVNetId = \"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroupName/providers/Microsoft.Network/virtualNetworks/MyHubVNetName\", MySpokeVnetId = \"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroupName/providers/Microsoft.Network/virtualNetworks/MySpokeVNetName\" }"
