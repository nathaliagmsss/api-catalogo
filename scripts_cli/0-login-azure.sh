echo "=========================================="
echo "PASSO 0: Login no Azure"
echo "=========================================="

# Fazer login
az login

# Listar assinaturas disponíveis
az account list --output table

# Definir assinatura ativa (se tiver mais de uma)
# az account set --subscription "NOME_OU_ID_DA_SUBSCRIPTION"

# Verificar assinatura ativa
az account show --output table

echo ""
echo "✅ Login realizado com sucesso!"
echo "📝 Anote o Subscription ID:"
az account show --query id -o tsv
echo ""