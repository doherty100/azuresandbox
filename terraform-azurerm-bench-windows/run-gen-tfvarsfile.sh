#!/bin/bash

# Helper script for gentfvarsfile.sh
# -n VM_NAME_PREFIX
# -s VM_DB_IMAGE_SKU
# -z VM_DB_SIZE
# -c VM_DB_DATA_DISK_COUNT
# -d VM_DB_DATA_DISK_SIZE_GB
# -S VM_WEB_IMAGE_SKU
# -Z VM_WEB_SIZE
# -t TAGS

./gen-tfvarsfile.sh \
  -n "winbench" \
  -s "sqldev" \
  -z "Standard_B4ms" \
  -c "2" \
  -d "32" \
  -S "2019-Datacenter-smalldisk" \
  -Z "Standard_B2s" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
