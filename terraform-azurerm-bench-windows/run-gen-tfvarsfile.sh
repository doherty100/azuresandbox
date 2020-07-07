#!/bin/bash

# Helper script for gentfvarsfile.sh
# -n VM_NAME
# -s VM_IMAGE_SKU
# -z VM_SIZE
# -c VM_DATA_DISK_COUNT
# -d VM_DATA_DISK_SIZE_GB\
# -t TAGS

./gen-tfvarsfile.sh \
  -n "sqldb01" \
  -s "sqldev" \
  -z "Standard_B2ms" \
  -c "2" \
  -d "32" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
