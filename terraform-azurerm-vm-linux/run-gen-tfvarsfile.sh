#!/bin/bash

# Helper script for gentfvarsfile.sh
# -n VM_NAME
# -s VM_IMAGE_SKU
# -z VM_SIZE
# -c VM_DATA_DISK_COUNT
# -d VM_DATA_DISK_SIZE_GB\
# -t TAGS

./gen-tfvarsfile.sh \
  -n "jumpbox01" \
  -s "18.04-LTS" \
  -z "Standard_B2ms" \
  -c "1" \
  -d "32" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
