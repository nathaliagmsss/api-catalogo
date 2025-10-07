#!/bin/bash
RESOURCE_GROUP="rg-catalog-api"
APP_SERVICE_NAME="app-catalog-api-1759851105" #Obtido do script 05

echo "Configurando variáveis de ambiente..."
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --settings \
    ASPNETCORE_ENVIRONMENT="Production" \
    WEBSITE_RUN_FROM_PACKAGE="1"

echo "Habilitando logs..."
az webapp log config \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --application-logging filesystem \
  --level information

echo "Configurações aplicadas!"