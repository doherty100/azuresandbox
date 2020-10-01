#!/bin/bash

# Helper script for gen-tfvarsfile.sh
# -d SQL_DATABASE_NAME
# -t TAGS

./gen-tfvarsfile.sh \
  -d "sqldb-benchmarktest-01"\
  -t "{ costcenter = \"MyCostCenter\", division = \"MyDivision\", group = \"MyGroup\" }"
