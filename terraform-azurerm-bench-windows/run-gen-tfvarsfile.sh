#!/bin/bash

# Helper script for gentfvarsfile.sh
# -n VM_NAME_PREFIX
# -s VM_DB_IMAGE_SKU
# -z VM_DB_SIZE
# -c VM_DB_DATA_DISK_CONFIG
# -S VM_WEB_IMAGE_SKU
# -Z VM_WEB_SIZE
# -t TAGS

./gen-tfvarsfile.sh \
  -n "winbench" \
  -s "sqldev" \
  -z "Standard_B4ms" \
  -c "{ datadisk = { name = \"dsk_sqldata_001\", disk_size_gb = \"128\", lun = \"0\", caching = \"ReadOnly\" }, logdisk = { name = \"dsk_sqllog_001\", disk_size_gb = \"32\", lun = \"1\", caching = \"None\" } }" \
  -S "2019-Datacenter-smalldisk" \
  -Z "Standard_B2s" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
