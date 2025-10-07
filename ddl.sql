-- =============================================
-- Script de Criação do Banco de Dados
-- Sistema de Categorias e Produtos
-- =============================================

-- Tabela Master: Categorias
CREATE TABLE Categorias (
                            Id INT PRIMARY KEY IDENTITY(1,1),
                            Nome NVARCHAR(100) NOT NULL,
                            Descricao NVARCHAR(500),
                            Ativo BIT NOT NULL DEFAULT 1,
                            DataCriacao DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Tabela Detail: Produtos
CREATE TABLE Produtos (
                          Id INT PRIMARY KEY IDENTITY(1,1),
                          Nome NVARCHAR(200) NOT NULL,
                          Descricao NVARCHAR(1000),
                          Preco DECIMAL(18,2) NOT NULL,
                          Estoque INT NOT NULL DEFAULT 0,
                          CategoriaId INT NOT NULL,
                          Ativo BIT NOT NULL DEFAULT 1,
                          DataCriacao DATETIME2 NOT NULL DEFAULT GETDATE(),
                          CONSTRAINT FK_Produtos_Categorias FOREIGN KEY (CategoriaId)
                              REFERENCES Categorias(Id)
                              ON DELETE CASCADE
);

-- Índices para melhor performance
CREATE INDEX IX_Produtos_CategoriaId ON Produtos(CategoriaId);
CREATE INDEX IX_Categorias_Nome ON Categorias(Nome);
CREATE INDEX IX_Produtos_Nome ON Produtos(Nome);

-- =============================================
-- Dados de Exemplo (Opcional)
-- =============================================

-- Inserir Categorias de exemplo
INSERT INTO Categorias (Nome, Descricao, Ativo) VALUES
                                                    ('Eletrônicos', 'Produtos eletrônicos e tecnologia', 1),
                                                    ('Alimentos', 'Produtos alimentícios', 1),
                                                    ('Vestuário', 'Roupas e acessórios', 1);

-- Inserir Produtos de exemplo
INSERT INTO Produtos (Nome, Descricao, Preco, Estoque, CategoriaId, Ativo) VALUES
                                                                               ('Notebook Dell', 'Notebook i7 16GB RAM', 3500.00, 10, 1, 1),
                                                                               ('Mouse Logitech', 'Mouse sem fio', 150.00, 50, 1, 1),
                                                                               ('Arroz Integral', 'Arroz integral 1kg', 12.50, 100, 2, 1),
                                                                               ('Camiseta Polo', 'Camiseta polo masculina', 89.90, 30, 3, 1);