#!/bin/bash
RESOURCE_GROUP="rg-catalog-api"
SQL_SERVER_NAME="" #Obtido do script 2

echo "Configurando firewall..."

# Permitir Azure Services
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name "AllowAzureServices" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Regra que permite qualquer IP (para demonstração acadêmica)
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name "AllowAllIPs-Demo" \
  --start-ip-address "0.0.0.0" \
  --end-ip-address "255.255.255.255"

echo "Firewall configurado para qualquer IP (para demonstração acadêmica)"