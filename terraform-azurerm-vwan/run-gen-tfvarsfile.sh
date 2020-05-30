#!/bin/bash

# Helper script for gen-tfvarsfile.sh
# -a VWAN_HUB_ADDRESS_PREFIX
# -t TAGS

./gen-tfvarsfile.sh \
  -a "10.3.0.0/16" \
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
