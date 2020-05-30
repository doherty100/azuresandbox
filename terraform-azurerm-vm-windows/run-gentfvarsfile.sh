#!/bin/bash

# Helper script for gentfvarsfile.sh
# -n VM_NAME
# -s VM_IMAGE_SKU
# -z VM_SIZE
# -c VM_DATA_DISK_COUNT
# -d VM_DATA_DISK_SIZE_GB\
# -t TAGS

./gentfvarsfile.sh \
  -n "jumpbox01" \
  -s "2019-Datacenter-smalldisk" \
  -z "Standard_B2ms" \
  -c "1" \
  -d "32" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
