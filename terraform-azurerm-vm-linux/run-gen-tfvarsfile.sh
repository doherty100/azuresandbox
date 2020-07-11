#!/bin/bash

# Helper script for gentfvarsfile.sh
# -n VM_NAME
# -p VM_IMAGE_PUBLISHER
# -o VM_IMAGE_OFFER
# -s VM_IMAGE_SKU
# -z VM_SIZE
# -c VM_DATA_DISK_COUNT
# -d VM_DATA_DISK_SIZE_GB\
# -t TAGS

./gen-tfvarsfile.sh \
  -n "jumpbox02" \
  -p "Canonical" \
  -o "UbuntuServer" \
  -s "18.04-LTS" \
  -z "Standard_B2s" \
  -c "0" \
  -d "0" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
