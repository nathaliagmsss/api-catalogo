
using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace AzureCatalogAPI.Models
{
    public class Categoria
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string? Descricao { get; set; }
        public bool Ativo { get; set; } = true;
        public DateTime DataCriacao { get; set; } = DateTime.Now;
        
        // Relacionamento
        public ICollection<Produto> Produtos { get; set; } = new List<Produto>();
    }
}