#!/bin/bash

# Builds the "production" side of the project: one resource group, one VNet, one small Linux VM running nginx, in West Europe.

# Deliberately minimal: one VM, no load balancer, no database tier.

set -euo pipefail

echo "Creating primary resource group: $RG_PRIMARY in $PRIMARY_REGION"
az group create --name "$RG_PRIMARY" --location "$PRIMARY_REGION"

echo "Creating VNet + subnet"
az network vnet create \
  --resource-group "$RG_PRIMARY" \
  --name "$VNET_PRIMARY" \
  --address-prefix 10.10.0.0/16 \
  --subnet-name "$SUBNET_NAME" \
  --subnet-prefix 10.10.1.0/24 \
  --location "$PRIMARY_REGION"

echo "Creating NSG (allow SSH + HTTP only)"
az network nsg create \
  --resource-group "$RG_PRIMARY" \
  --name "nsg-${PROJECT}-web" \
  --location "$PRIMARY_REGION"

az network nsg rule create \
  --resource-group "$RG_PRIMARY" \
  --nsg-name "nsg-${PROJECT}-web" \
  --name "Allow-SSH" \
  --priority 1000 \
  --destination-port-ranges 22 \
  --access Allow --protocol Tcp

az network nsg rule create \
  --resource-group "$RG_PRIMARY" \
  --nsg-name "nsg-${PROJECT}-web" \
  --name "Allow-HTTP" \
  --priority 1010 \
  --destination-port-ranges 80 \
  --access Allow --protocol Tcp

az network vnet subnet update \
  --resource-group "$RG_PRIMARY" \
  --vnet-name "$VNET_PRIMARY" \
  --name "$SUBNET_NAME" \
  --network-security-group "nsg-${PROJECT}-web"

echo "Creating VM"
az vm create \
  --resource-group "$RG_PRIMARY" \
  --name "$VM_NAME" \
  --image "Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest" \
  --size "$VM_SIZE" \
  --vnet-name "$VNET_PRIMARY" \
  --subnet "$SUBNET_NAME" \
  --admin-username "$ADMIN_USER" \
  --ssh-key-values ~/.ssh/azure_dr_project.pub \
  --public-ip-sku Standard


echo "Installing nginx via cloud-init extension"
az vm extension set \
  --resource-group "$RG_PRIMARY" \
  --vm-name "$VM_NAME" \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"commandToExecute":"apt-get update && apt-get install -y nginx && echo \"<h1>Primary region - West Europe</h1>\" > /var/www/html/index.html"}'

PUBLIC_IP=$(az vm show -d --resource-group "$RG_PRIMARY" --name "$VM_NAME" --query publicIps -o tsv)
echo ""
echo "DONE"
echo "VM public IP: $PUBLIC_IP"
echo "Test it: curl http://$PUBLIC_IP  (or open in a browser)"
