# 🚀 Azure Catalog API - Guia Completo de Deploy

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Azure CLI** (versão 2.0 ou superior)
  ```bash
  # Verificar instalação
  az --version
  
  # Instalar no macOS
  brew update && brew install azure-cli
  
  # Instalar no Windows
  # Baixe o instalador em: https://aka.ms/installazurecliwindows
  
  # Instalar no Linux
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  ```

- **.NET SDK 9.0** ou superior
  ```bash
  # Verificar instalação
  dotnet --version
  
  # Baixar em: https://dotnet.microsoft.com/download
  ```

- **Conta Azure** ativa
  - Acesse: https://portal.azure.com
  - Crie uma conta gratuita se necessário

---

## 🔐 1. Login no Azure

```bash
# Fazer login na sua conta Azure
az login

# Verificar a conta ativa
az account show

# Se tiver múltiplas assinaturas, selecione a desejada
az account list --output table
az account set --subscription "NOME_OU_ID_DA_SUBSCRIPTION"
```

---

## 📁 2. Estrutura do Projeto

```
AzureCatalogAPI/
├── Controllers/
│   ├── CategoriasController.cs
│   ├── ProdutosController.cs
│   └── HealthController.cs
├── Data/
│   └── AppDbContext.cs
├── Models/
│   ├── Categoria.cs
│   └── Produto.cs
├── scripts_cli/
│   ├── 0-login-azure.sh
│   ├── 01-create-resource-group.sh
│   ├── 02-create-sql-server.sh
│   ├── 03-02-create-app-insights.sh
│   ├── 03-create-sql-database.sh
│   ├── 04-configure-firewall.sh
│   ├── 05-create-app-service-plan.sh
│   ├── 06-create-webapp.sh
│   ├── 07-configure-app-settings.sh
│   └── 08-deploy-application.sh
├── appsettings.json
├── appsettings.development.json
├── ddl.sql
├── Program.cs
├── AzureCatalogAPI.csproj
└── README.md
```

---

## 🎯 3. Deploy Passo a Passo

### 3.1. Criar Resource Group

```bash
cd scripts_cli
chmod +x *.sh  # Dar permissão de execução (macOS/Linux)

./scripts_cli/01-create-resource-group.sh
```

**O que isso faz:**
- Cria um grupo de recursos no Azure
- Região: East US 2
- Nome: `rg-catalog-api`

---

### 3.2. Criar SQL Server

```bash
./scripts_cli/02-create-sql-server.sh
```

**O que isso faz:**
- Cria um Azure SQL Server
- Usuário admin: `fiapAdmin`
- Senha: `FiapAmin2025!`
- ⚠️ **IMPORTANTE:** Anote o nome do servidor que aparece no final!

**Exemplo de output:**
```
SQL Server criado: sqlsrv-catalog-api1759850557.database.windows.net
Salve este nome para os próximos scripts!
```

---

### 3.3. Criar Database

```bash
./scripts_cli/03-create-sql-database.sh
```

**O que isso faz:**
- Cria um banco de dados SQL no servidor
- Nome: `catalogodb`
- Tier: Basic (econômico)

---

### 3.4. Configurar Firewall

```bash
./scripts_cli/04-configure-firewall.sh
```

**O que isso faz:**
- Permite acesso ao banco de dados do Azure
- Permite acesso da sua máquina local (desenvolvimento)
- ⚠️ **ATENÇÃO:** Remove a regra "AllowAllIPs" em produção!

---

### 3.5. Criar Tabelas no Banco

Agora você precisa executar o script SQL para criar as tabelas:

**Opção 1: Via Azure Portal**
1. Acesse: https://portal.azure.com
2. Vá em "SQL databases"
3. Selecione `catalogodb`
4. Clique em "Query editor"
5. Faça login com:
   - Usuário: `fiapAdmin`
   - Senha: `FiapAmin2025!`
6. Cole o conteúdo de `ddl.sql`
7. Clique em "Run"

---

### 3.6. Criar App Service Plan

```bash
./scripts_cli/05-create-app-service-plan.sh
```

**O que isso faz:**
- Cria um plano de serviço Linux
- Tier: B1 (Basic)
- Suporta aplicações .NET 9.0

---

### 3.7. Criar Web App

```bash
./scripts_cli/06-create-webapp.sh
```

**O que isso faz:**
- Cria a aplicação web
- Runtime: .NET 9.0
- Sistema Operacional: Linux
- ⚠️ **IMPORTANTE:** Anote a URL que aparece no final!

**Exemplo de output:**
```
Web App criada: https://app-catalog-api-1759851105.azurewebsites.net
```

3.8. Configurar Arquivos de Configuração
⚠️ IMPORTANTE: Antes de fazer o deploy, você precisa configurar os arquivos appsettings.json:
appsettings.Development.json (Desenvolvimento Local)

```
json{
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft.AspNetCore": "Information"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=CatalogDB;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
appsettings.json (Produção - NÃO comitar senhas!)
json{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=<SEU_SERVIDOR>;Database=<SEU_BANCO>;User Id=<USUARIO>;Password=<SENHA>;Encrypt=True;TrustServerCertificate=False;"
  },
  "ApplicationInsights": {
    "ConnectionString": "<SUA_CHAVE_APP_INSIGHTS>"
  }
}
```
📝 Valores a substituir no appsettings.json:

```
<SEU_SERVIDOR>: Ex: sqlsrv-catalog-api1759850557.database.windows.net
<SEU_BANCO>: catalogodb
<USUARIO>: fiapAdmin
<SENHA>: FiapAmin2025!
<SUA_CHAVE_APP_INSIGHTS>
```

🔒 Segurança:

NUNCA commite o appsettings.json com senhas reais no Git!
Adicione appsettings.json no .gitignore
Use placeholders (<...>) no repositório
Configure as connection strings via Azure CLI (próximo passo)

---

### 3.9. Configurar Connection String

```bash
./scripts_cli/07-configure-app-settings.sh
```

**⚠️ ANTES DE EXECUTAR:**
1. Abra o arquivo `/scripts_cli/07-configure-app-settings.sh`
2. Substitua os valores:
   - `SQL_SERVER_NAME`: Nome do seu SQL Server (passo 3.2)
   - `WEBAPP_NAME`: Nome do seu Web App (passo 3.7)

**O que isso faz:**
- Configura a connection string do banco de dados
- Configura variáveis de ambiente
- Define o ambiente como Production
---

### 3.10. Pré Deploy da Aplicação

```bash
	dotnet publish -c Release -o ./publish
cd publish && zip -r ../publish.zip .
cd ..
./scripts_cli/08-deploy-application.sh
```

---

### 3.11. Deploy da Aplicação

```bash
./scripts_cli/08-deploy-application.sh
```

**⚠️ ANTES DE EXECUTAR:**
1. Volte para a raiz do projeto: `cd ..`
2. Abra o arquivo `scripts_cli/08-deploy-application.sh`
3. Substitua `WEBAPP_NAME` pelo nome do seu Web App

```bash
./scripts_cli/08-deploy-application.sh
```


**O que isso faz:**
- Compila a aplicação .NET
- Publica os arquivos
- Cria um arquivo .zip
- Faz o upload para o Azure
- Aguarde cerca de 2-3 minutos

---

## ✅ 4. Verificar o Deploy

### 4.1. Testar a API

```bash
# Testar endpoint raiz
curl https://SEU-WEBAPP.azurewebsites.net/

# Testar health check
curl https://SEU-WEBAPP.azurewebsites.net/api/health

# Listar categorias
curl https://SEU-WEBAPP.azurewebsites.net/api/categorias

# Listar produtos
curl https://SEU-WEBAPP.azurewebsites.net/api/produtos
```

### 4.2. Acessar Swagger

Abra no navegador:
```
https://SEU-WEBAPP.azurewebsites.net/swagger
```

### 4.3. Ver Logs em Tempo Real

```bash
az webapp log tail \
  --name SEU-WEBAPP-NAME \
  --resource-group rg-catalog-api
```

---

## 🔧 5. Comandos Úteis

### Verificar Status dos Recursos

```bash
# Listar todos os recursos no Resource Group
az resource list \
  --resource-group rg-catalog-api \
  --output table

# Ver detalhes do Web App
az webapp show \
  --name SEU-WEBAPP-NAME \
  --resource-group rg-catalog-api

# Ver connection strings configuradas
az webapp config connection-string list \
  --name SEU-WEBAPP-NAME \
  --resource-group rg-catalog-api
```

### Reiniciar a Aplicação

```bash
az webapp restart \
  --name SEU-WEBAPP-NAME \
  --resource-group rg-catalog-api
```

### Ver Logs de Deploy

```bash
az webapp log deployment show \
  --name SEU-WEBAPP-NAME \
  --resource-group rg-catalog-api
```

---

## 📊 6. Endpoints da API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/` | Status da API |
| GET | `/api/health` | Health check |
| GET | `/api/categorias` | Listar todas categorias |
| GET | `/api/categorias/{id}` | Obter categoria por ID |
| POST | `/api/categorias` | Criar nova categoria |
| PUT | `/api/categorias/{id}` | Atualizar categoria |
| DELETE | `/api/categorias/{id}` | Deletar categoria |
| GET | `/api/produtos` | Listar todos produtos |
| GET | `/api/produtos/{id}` | Obter produto por ID |
| POST | `/api/produtos` | Criar novo produto |
| PUT | `/api/produtos/{id}` | Atualizar produto |
| DELETE | `/api/produtos/{id}` | Deletar produto |
| GET | `/swagger` | Documentação Swagger |

---

## 🧪 7. Testar com cURL

### Criar uma Categoria

```bash
curl -X POST https://SEU-WEBAPP.azurewebsites.net/api/categorias \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Eletrônicos",
    "descricao": "Produtos eletrônicos e tecnologia",
    "ativo": true
  }'
```

### Criar um Produto

```bash
curl -X POST https://SEU-WEBAPP.azurewebsites.net/api/produtos \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Notebook Dell",
    "descricao": "Notebook i7 16GB RAM",
    "preco": 3500.00,
    "estoque": 10,
    "categoriaId": 1,
    "ativo": true
  }'
```

### Listar Categorias

```bash
curl https://SEU-WEBAPP.azurewebsites.net/api/categorias
```

---

## 🛠️ 8. Troubleshooting

### Problema: Erro 500 ao acessar a API

**Solução:**
```bash
# Ver logs detalhados
az webapp log tail \
  --name SEU-WEBAPP-NAME \
  --resource-group rg-catalog-api

# Verificar se a connection string está configurada
az webapp config connection-string list \
  --name SEU-WEBAPP-NAME \
  --resource-group rg-catalog-api
```

### Problema: Não consegue conectar ao banco

**Solução:**
```bash
# Verificar regras de firewall
az sql server firewall-rule list \
  --resource-group rg-catalog-api \
  --server SEU-SQL-SERVER-NAME

# Adicionar seu IP
az sql server firewall-rule create \
  --resource-group rg-catalog-api \
  --server SEU-SQL-SERVER-NAME \
  --name AllowMyIP \
  --start-ip-address SEU-IP \
  --end-ip-address SEU-IP
```

### Problema: Deploy falhou

**Solução:**
```bash
# Limpar cache e tentar novamente
cd ..
rm -rf bin obj publish publish.zip
./scripts_cli/08-deploy-application.sh
```

---

## 🗑️ 9. Limpar Recursos (Deletar tudo)

⚠️ **ATENÇÃO:** Isso deletará TODOS os recursos e dados!

```bash
az group delete \
  --name rg-catalog-api \
  --yes \
  --no-wait
```

---

## 💰 10. Custos Estimados

Com a configuração Basic:
- **SQL Database (Basic):** ~R$ 25/mês
- **App Service (B1):** ~R$ 55/mês
- **Total:** ~R$ 80/mês

💡 **Dica:** Use o Azure Calculator para estimativas precisas: https://azure.microsoft.com/pricing/calculator/

---

## 📚 11. Recursos Adicionais

- [Documentação Azure CLI](https://docs.microsoft.com/cli/azure/)
- [Azure App Service](https://docs.microsoft.com/azure/app-service/)
- [Azure SQL Database](https://docs.microsoft.com/azure/azure-sql/)
- [.NET no Azure](https://docs.microsoft.com/dotnet/azure/)

---

## 🤝 12. Suporte

Se encontrar problemas:
1. Verifique os logs: `az webapp log tail`
2. Consulte a documentação oficial
3. Abra uma issue no repositório

---

## ✅ Checklist Final

- [ ] Azure CLI instalado e configurado
- [ ] .NET 9.0 SDK instalado
- [ ] Login no Azure realizado
- [ ] Resource Group criado
- [ ] SQL Server criado
- [ ] Database criado e tabelas criadas
- [ ] Firewall configurado
- [ ] App Service Plan criado
- [ ] Web App criado
- [ ] Connection String configurada
- [ ] Aplicação deployada
- [ ] API testada e funcionando

---

**🎉 Parabéns! Sua API está no ar!**

Acesse: `https://SEU-WEBAPP.azurewebsites.net/swagger`
