#!/bin/bash

set -e

action=$1
shift 1
other=$@

subscription="MOCK_VALUE"

if [ -z "$action" ]; then
  echo "Missed action: init, apply, plan, destroy"
  exit 0
fi

# shellcheck source=/dev/null
source "./backend.ini"

az account set -s "${subscription}"

terraform init
terraform "$action" $other
