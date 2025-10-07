#!/bin/bash
# =============================================
# Script de Deploy Completo no Azure
# =============================================

# Variáveis - ALTERE CONFORME NECESSÁRIO
RESOURCE_GROUP="rg-catalog-api"
LOCATION="brazilsouth"
SQL_SERVER_NAME="sqlserver-catalog-$(date +%s)"
SQL_DB_NAME="CatalogDB"
SQL_ADMIN_USER="sqladmin"
SQL_ADMIN_PASSWORD="SuaSenhaForte123!"  # ALTERE ESTA SENHA
APP_SERVICE_PLAN="plan-catalog-api"
WEB_APP_NAME="webapp-catalog-api-$(date +%s)"
APP_INSIGHTS_NAME="appi-catalog-api"

echo "======================================"
echo "Iniciando criação de recursos Azure"
echo "======================================"

# 1. Fazer login no Azure (se necessário)
echo "1. Verificando login no Azure..."
az account show || az login

# 2. Criar Resource Group
echo "2. Criando Resource Group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# 3. Criar SQL Server
echo "3. Criando SQL Server..."
az sql server create \
  --name $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --admin-user $SQL_ADMIN_USER \
  --admin-password $SQL_ADMIN_PASSWORD

# 4. Configurar Firewall do SQL Server (permitir serviços Azure)
echo "4. Configurando Firewall do SQL Server..."
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Permitir seu IP local (opcional - para testes)
MY_IP=$(curl -s https://api.ipify.org)
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name AllowMyIP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP

# 5. Criar Banco de Dados
echo "5. Criando Banco de Dados..."
az sql db create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name $SQL_DB_NAME \
  --service-objective S0

# 6. Criar Application Insights
echo "6. Criando Application Insights..."
az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --application-type web

# Obter Instrumentation Key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv)

# Obter Connection String
APP_INSIGHTS_CONN=$(az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query connectionString -o tsv)

# 7. Criar App Service Plan
echo "7. Criando App Service Plan..."
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku B1 \
  --is-linux

# 8. Criar Web App
echo "8. Criando Web App..."
az webapp create \
  --name $WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --runtime "DOTNET|8.0"

# 9. Configurar Connection String no Web App
echo "9. Configurando Connection String..."
SQL_CONNECTION_STRING="Server=tcp:${SQL_SERVER_NAME}.database.windows.net,1433;Database=${SQL_DB_NAME};User ID=${SQL_ADMIN_USER};Password=${SQL_ADMIN_PASSWORD};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

az webapp config connection-string set \
  --name $WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --connection-string-type SQLAzure \
  --settings DefaultConnection="$SQL_CONNECTION_STRING"

# 10. Configurar Application Insights no Web App
echo "10. Configurando Application Insights..."
az webapp config appsettings set \
  --name $WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    APPLICATIONINSIGHTS_CONNECTION_STRING="$APP_INSIGHTS_CONN" \
    ApplicationInsights__ConnectionString="$APP_INSIGHTS_CONN"

# 11. Deploy da aplicação (se tiver o código localmente)
echo "11. Realizando deploy da aplicação..."
# Certifique-se de estar na pasta do projeto
# dotnet publish -c Release -o ./publish
# cd ./publish
# zip -r ../app.zip .
# cd ..
# az webapp deployment source config-zip \
#   --resource-group $RESOURCE_GROUP \
#   --name $WEB_APP_NAME \
#   --src app.zip

echo "======================================"
echo "Recursos criados com sucesso!"
echo "======================================"
echo ""
echo "Informações importantes:"
echo "Resource Group: $RESOURCE_GROUP"
echo "SQL Server: $SQL_SERVER_NAME.database.windows.net"
echo "Database: $SQL_DB_NAME"
echo "SQL User: $SQL_ADMIN_USER"
echo "Web App URL: https://${WEB_APP_NAME}.azurewebsites.net"
echo "App Insights: $APP_INSIGHTS_NAME"
echo ""
echo "Connection String:"
echo "$SQL_CONNECTION_STRING"
echo ""
echo "Application Insights Connection String:"
echo "$APP_INSIGHTS_CONN"
echo ""
echo "======================================"
echo "Próximos passos:"
echo "1. Execute o script DDL no SQL Database"
echo "2. Configure o GitHub Actions com o publish profile"
echo "3. Faça push do código para o GitHub"
echo "======================================"

# Salvar informações em arquivo
cat > azure-resources-info.txt <<EOF
Resource Group: $RESOURCE_GROUP
SQL Server: $SQL_SERVER_NAME.database.windows.net
Database: $SQL_DB_NAME
SQL User: $SQL_ADMIN_USER
SQL Password: $SQL_ADMIN_PASSWORD
Web App URL: https://${WEB_APP_NAME}.azurewebsites.net
App Insights: $APP_INSIGHTS_NAME

Connection String:
$SQL_CONNECTION_STRING

Application Insights Connection String:
$APP_INSIGHTS_CONN
EOF

echo "Informações salvas em: azure-resources-info.txt"