#!/bin/bash
RG="rg-contoso-health-lab"
LOCATION="eastus"

az group create --name $RG --location $LOCATION

az network vnet create \
  --resource-group $RG \
  --name vnet-contoso-health \
  --address-prefix 10.0.0.0/16 \
  --subnet-name snet.servers.windows \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group $RG \
  --vnet-name vnet-contoso-health \
  --name snet-servers-linux \
  --address-prefix 10.0.2.0/24

echo "Base network deployed successfully Barron!"
