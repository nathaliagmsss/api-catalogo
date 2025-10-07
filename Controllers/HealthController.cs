using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AzureCatalogAPI.Data;

namespace AzureCatalogAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HealthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public HealthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            try
            {
                // Testa conexão com o banco
                var canConnect = await _context.Database.CanConnectAsync();
                
                // Conta categorias
                var categoriasCount = await _context.Categorias.CountAsync();
                
                // Conta produtos
                var produtosCount = await _context.Produtos.CountAsync();

                return Ok(new
                {
                    status = "healthy",
                    database = new
                    {
                        canConnect = canConnect,
                        categoriasCount = categoriasCount,
                        produtosCount = produtosCount
                    },
                    environment = _configuration["ASPNETCORE_ENVIRONMENT"]
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    status = "unhealthy",
                    error = ex.Message,
                    innerError = ex.InnerException?.Message
                });
            }
        }

        [HttpGet("connection")]
        public IActionResult GetConnectionString()
        {
            var connectionString = _configuration.GetConnectionString("DefaultConnection");
            var hasConnection = !string.IsNullOrEmpty(connectionString);
            
            // Mascara a senha para segurança
            var maskedConnection = connectionString?.Replace(
                connectionString.Split("Password=")[1].Split(";")[0], 
                "****"
            ) ?? "NOT FOUND";

            return Ok(new
            {
                hasConnectionString = hasConnection,
                connectionString = maskedConnection
            });
        }
    }
}