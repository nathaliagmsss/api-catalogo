using Microsoft.EntityFrameworkCore;
using AzureCatalogAPI.Data;

var builder = WebApplication.CreateBuilder(args);

Console.WriteLine("Startup : " + DateTime.Now.ToString("hh.mm.ss.ffffff"));

// Add services to the container.
// IMPORTANTE: Esta configuração previne o erro de ciclo circular!
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
    });

Console.WriteLine("Configure Services : " + DateTime.Now.ToString("hh.mm.ss.ffffff"));

// Configuração do banco de dados
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? builder.Configuration.GetConnectionString("FiapAzureDb");

if (string.IsNullOrEmpty(connectionString))
{
    Console.WriteLine("ERRO: Connection string não encontrada!");
    throw new InvalidOperationException("Connection string 'DefaultConnection' ou 'FiapAzureDb' não foi encontrada.");
}

Console.WriteLine($"Connection string configurada com sucesso!");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

// Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Application Insights
builder.Services.AddApplicationInsightsTelemetry();

// CORS configuration
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
});

Console.WriteLine("Configure : " + DateTime.Now.ToString("hh.mm.ss.ffffff"));

var app = builder.Build();

Console.WriteLine("Setting Up Routes : " + DateTime.Now.ToString("hh.mm.ss.ffffff"));

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("AllowAll");

// Remover HTTPS redirect para evitar warning nos logs
// app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

// Endpoint de teste na raiz
app.MapGet("/", () => new
{
    status = "API está rodando!",
    version = "1.0",
    timestamp = DateTime.Now,
    endpoints = new[]
    {
        "/api/categorias",
        "/api/produtos",
        "/api/health",
        "/swagger"
    }
});

Console.WriteLine("Exiting Configure : " + DateTime.Now.ToString("hh.mm.ss.ffffff"));

app.Run();