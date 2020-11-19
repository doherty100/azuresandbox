#!/bin/bash

# Helper script for gentfvarsfile.sh
# -n VM_NAME_PREFIX
# -s VM_DB_IMAGE_SKU
# -z VM_DB_SIZE
# -c VM_DB_DATA_DISK_CONFIG
# -S VM_APP_IMAGE_SKU
# -Z VM_APP_SIZE
# -t TAGS

./gen-tfvarsfile.sh \
  -n "winbench" \
  -s "sqldev" \
  -z "Standard_B4ms" \
  -c "{ sqldata = { name = \"vol_sqldata_F\", disk_size_gb = \"128\", lun = \"0\", caching = \"ReadOnly\" }, sqllog = { name = \"vol_sqllog_L\", disk_size_gb = \"32\", lun = \"1\", caching = \"None\" } }" \
  -S "2019-Datacenter-smalldisk" \
  -Z "Standard_B2s" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
