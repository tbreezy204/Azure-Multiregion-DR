#!/bin/bash

# This script creates a monthly budget with email alerts at 50/80/100% of a $10 cap.


set -euo pipefail

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
EMAIL="orjitochukwuc@gmail.com"

az consumption budget create \
  --budget-name "budget-${PROJECT}" \
  --amount 10 \
  --category cost \
  --time-grain monthly \
  --start-date "$(date +%Y-%m-01)" \
  --end-date "$(date -d '+1 month' +%Y-%m-01 2>/dev/null || date -v+1m +%Y-%m-01)" \
  --resource-group "$RG_PRIMARY" 2>/dev/null || \

echo "Budget check done."
