#!/bin/bash
RESOURCE_GROUP="rg-catalog-api"
LOCATION="eastus2"
APP_SERVICE_PLAN="asp-catalog-api"
APP_SERVICE_NAME="app-catalog-api-$(date +%s)"

echo "Criando App Service Plan..."
az appservice plan create \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_PLAN \
  --location $LOCATION \
  --sku B1 \
  --is-linux

echo "Criando App Service..."
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $APP_SERVICE_NAME \
  --runtime "DOTNETCORE|9.0"

echo "App Service criado: https://$APP_SERVICE_NAME.azurewebsites.net"
echo "Salve este nome para a configuração!"