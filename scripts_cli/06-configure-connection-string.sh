#!/bin/bash
RESOURCE_GROUP="rg-catalog-api"
SQL_SERVER_NAME="" #Obtido do script 02
SQL_DATABASE_NAME="catalogodb"
SQL_ADMIN_USER="fiapAdmin"
SQL_ADMIN_PASSWORD="FiapAmin2025!"
APP_SERVICE_NAME="" #Obtido do script 05

CONNECTION_STRING="Server=tcp:${SQL_SERVER_NAME}.database.windows.net,1433;Initial Catalog=${SQL_DATABASE_NAME};Persist Security Info=False;User ID=${SQL_ADMIN_USER};Password=${SQL_ADMIN_PASSWORD};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

echo "Configurando Connection String..."
az webapp config connection-string set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --connection-string-type SQLServer \
  --settings FiapAzureDb="$CONNECTION_STRING"

echo "Connection String configurada!"