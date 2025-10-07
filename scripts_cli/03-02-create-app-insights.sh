# 6. Criar Application Insights
echo "6. Criando Application Insights..."

LOCATION="eastus2"
APP_INSIGHTS_NAME="appi-catalog-api"
RESOURCE_GROUP="rg-catalog-api"

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