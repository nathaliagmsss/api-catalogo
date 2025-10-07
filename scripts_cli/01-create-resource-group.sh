#!/bin/bash
RESOURCE_GROUP="rg-catalog-api"
LOCATION="eastus2"

echo "Criando Resource Group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags "Environment=Development" "Project=FIAP-DevOps" "Owner=Nathalia"

echo "Resource Group criado: $RESOURCE_GROUP"