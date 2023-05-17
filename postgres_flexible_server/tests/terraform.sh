#!/bin/bash

set -e

action=$1
shift 1
other=$@

subscription="MOCK_VALUE"

case $action in
    "clean" )
        rm -rf .terraform* terraform.tfstate*
        echo "cleaned..."
        ;;
    * )
        # shellcheck source=/dev/null
        if [ -e "./backend.ini" ]; then
          source ./backend.ini
        else
          echo "Error: no backend.ini found!"
          exit 1
        fi

        az account set -s "${subscription}"

        terraform init
        terraform "$action" $other
        ;;
esac
