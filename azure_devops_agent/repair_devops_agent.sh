#!/usr/bin/env bash

# usage: ./repair_devops_agent.sh SUBSCRIPTION

SUBSCRIPTION=$1

#
# Pre checks
#
if [ -z "${SUBSCRIPTION}" ]; then
  printf "\e[1;31mYou must provide a SUBSCRIPTION as first argument.\n"
  exit 1
fi

az account set -s $1

vm_scaleset_name=$(az vmss list -o tsv --query "[?contains(name,'azdo')].{Name:name}" | head -1)
echo "[INFO] vm_scaleset_name: ${vm_scaleset_name}"
vm_scaleset_resource_group=$(az vmss list -o tsv --query "[?contains(name,'azdo')].{resourceGroup:resourceGroup}" | head -1)
echo "[INFO] vm_scaleset_resource_group: ${vm_scaleset_resource_group}"

az vmss extension delete \
  --vmss-name "${vm_scaleset_name}" \
  --resource-group "${vm_scaleset_resource_group}" \
  --name "Microsoft.Azure.DevOps.Pipelines.Agent"


sleep 30

az vmss extension set \
  --vmss-name "${vm_scaleset_name}" \
  --resource-group "${vm_scaleset_resource_group}" \
  --name "TeamServicesAgentLinux" \
  --version 1.22 \
  --publisher "Microsoft.VisualStudio.Services" \
  --extension-instance-name "Microsoft.Azure.DevOps.Pipelines.Agent" \
  --settings "./devops_agent.json"
