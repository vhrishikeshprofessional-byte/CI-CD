var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();

var app = builder.Build();

app.MapGet("/", () => Results.Ok(new
{
    Message = "Hello from .NET 8 Web API!",
    Timestamp = DateTime.UtcNow
}));

app.MapGet("/health", () => Results.Ok(new { Status = "Healthy" }));

app.Run();

// Required for WebApplicationFactory in integration/unit tests
public partial class Program { }
