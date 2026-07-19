#!/bin/bash

# This script Confirms Azure CLI is installed, logs in, sets subscription, and defines the environment variables every other script in this project depends on.

set -euo pipefail

echo "== Checking Azure CLI =="
az version || { echo "Install Azure CLI first: https://learn.microsoft.com/cli/azure/install-azure-cli"; exit 1; }

echo "== Logging in =="
az login --use-device-code

echo "== Available subscriptions =="
az account list --output table

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az account set --subscription "$SUBSCRIPTION_ID"

echo "Using subscription: $SUBSCRIPTION_ID"

# Shared variables used by every script in this project
export PROJECT="azure-multiregion-dr"
export PRIMARY_REGION="westeurope"
export DR_REGION="northeurope"
export RG_PRIMARY="rg-${PROJECT}-primary"
export RG_DR="rg-${PROJECT}"
export $VAULT_NAME2="rsv-azure-multiregion-dr-ne"
export VNET_PRIMARY="vnet-${PROJECT}-primary"
export VNET_DR="vnet-${PROJECT}"
export SUBNET_NAME="subnet-web"
export VM_NAME="vm-${PROJECT}-web01"
export VM_SIZE="Standard_D2s_v3"
export ADMIN_USER="azureuser"

echo ""
echo "Environment variables set for this shell session."
