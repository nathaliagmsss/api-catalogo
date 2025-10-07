#!/bin/bash
RESOURCE_GROUP="rg-catalog-api"
APP_SERVICE_NAME="app-catalog-api-1759851105" #Obtido do script 05

echo "Fazendo deploy da aplicação..."

# Certificar que você tem o arquivo publish.zip na pasta atual
if [ ! -f "publish.zip" ]; then
    echo "ERRO: arquivo publish.zip não encontrado!"
    echo "Execute primeiro: dotnet publish -c Release -o ./publish"
    echo "Depois: cd publish && zip -r ../publish.zip ."
    exit 1
fi

az webapp deployment source config-zip \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --src ./publish.zip

echo "Deploy concluído!"
echo "Acesse: https://$APP_SERVICE_NAME.azurewebsites.net"