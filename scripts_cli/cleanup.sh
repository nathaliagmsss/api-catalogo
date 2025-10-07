#!/bin/bash
# =============================================================================
# Script para deletar todos os recursos Azure
# =============================================================================

RESOURCE_GROUP="rg-catalog-api"

echo "ATENÇÃO: Este script vai DELETAR todos os recursos Azure!"
echo "Resource Group: $RESOURCE_GROUP"
echo ""
read -p "Tem certeza? (digite 'yes' para confirmar): " confirm

if [ "$confirm" = "yes" ]; then
    echo "Deletando Resource Group e todos os recursos..."
    az group delete --name $RESOURCE_GROUP --yes --no-wait
    echo "Deleção iniciada em background..."
    echo "Aguarde alguns minutos para a deleção completa."
    echo ""
    echo "Para verificar o status:"
    echo "az group show --name $RESOURCE_GROUP"
else
    echo "Operação cancelada."
fi