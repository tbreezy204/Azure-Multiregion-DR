#!/bin/bash
# 04-cleanup.sh
# Tears everything down so nothing keeps billing after today.
# Order matters: disable replication BEFORE deleting resource groups,
# otherwise the vault can leave orphaned protection state behind.

set -euo pipefail
# Run: source 00-prereqs.sh   first, in the same shell.

echo "== STEP 1: Disable replication (do this in Portal — it's the safest way) =="
echo "Vault ($VAULT_NAME) > Replicated items > $VM_NAME > Disable Replication > Confirm"
echo "Wait for this to show 'Completed' before continuing."
read -p "Press Enter once replication is disabled in the Portal..."

echo "== STEP 2: Delete the DR resource group (VNet + any leftover DR artifacts) =="
az group delete --name "$RG_DR" --yes --no-wait

echo "== STEP 3: Delete the primary resource group (VM, VNet, NSG, disks, IP) =="
az group delete --name "$RG_PRIMARY" --yes --no-wait

echo ""
echo "Both resource groups are deleting in the background (--no-wait)."
echo "Check progress: az group list --output table"
echo ""
echo "== STEP 4: Verify nothing is left =="
echo "Portal > Cost Management > Cost analysis — filter by resource group name"
echo "to confirm no unexpected residual resources (orphaned disks, snapshots,"
echo "public IPs, or NSGs are the usual culprits people forget)."
echo ""
echo "== STEP 5: Delete the Recovery Services Vault itself if it survived =="
echo "(Vaults sometimes need protected items fully removed before they'll delete.)"
echo "az backup vault delete --name $VAULT_NAME --resource-group $RG_PRIMARY --yes"
