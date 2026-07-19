#!/bin/bash


# Creates the Recovery Services Vault in the primary region and the DR resource group + VNet in the secondary region. The ASR replication setup is done manually in the Portal.

set -euo pipefail

echo "Creating DR resource group: $RG_DR in $DR_REGION"
az group create --name "$RG_DR" --location "$DR_REGION"

echo "Creating DR VNet"
az network vnet create \
  --resource-group "$RG_DR" \
  --name "$VNET_DR" \
  --address-prefix 10.20.0.0/16 \
  --subnet-name "$SUBNET_NAME" \
  --subnet-prefix 10.20.1.0/24 \
  --location "$DR_REGION"

echo "Creating Recovery Services Vault in PRIMARY region"
az backup vault create \
  --resource-group "$RG_PRIMARY" \
  --name "$VAULT_NAME" \
  --location "$PRIMARY_REGION" 2>/dev/null || \
az deployment group create \
  --resource-group "$RG_PRIMARY" \
  --template-uri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.recoveryservices/recovery-services-vault-create/azuredeploy.json" \
  --parameters vaultName="$VAULT_NAME2" vaultStorageRedundancy="LocallyRedundant" enableCRR=false

echo ""
echo "Recovery Services Vault created. Next step: configure ASR replication in the Portal." 