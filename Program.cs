var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddAWSLambdaHosting(LambdaEventSource.RestApi);

var app = builder.Build();
var users = new List<string> { "Alice", "Bob", "Charlie" };
var products = new List<string> { "Product A", "Product B", "Product C" };

// Add an endpoint to list the users
app.MapGet("/users", (Func<IEnumerable<string>>)(() => users));
// Add an endpoint to list the products
app.MapGet("/products", (Func<IEnumerable<string>>)(() => products));

// Configure the application to return JSON responses
app.Use(async (context, next) =>
{
    context.Response.ContentType = "application/json";
    await next();
});

app.Run();
