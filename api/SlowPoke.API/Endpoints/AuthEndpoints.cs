using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using SlowPoke.API.Models;

namespace SlowPoke.API.Endpoints;

public static class AuthEndpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/auth");

        group.MapPost("/login", LoginAsync)
             .AllowAnonymous()
             .WithName("Login");

        group.MapPost("/logout", LogoutAsync)
             .RequireAuthorization()
             .WithName("Logout");

        return app;
    }

    private static async Task<IResult> LoginAsync(
        LoginRequest request,
        IConfiguration configuration,
        HttpContext context)
    {
        var configPassword = configuration["Auth:Password"]
            ?? configuration["Auth:DefaultPassword"];

        if (string.IsNullOrEmpty(configPassword))
        {
            return Results.Problem("Server configuration error: Password not set");
        }

        if (request.Password != configPassword)
        {
            return Results.Json(
                new { error = "Invalid password" },
                statusCode: 401);
        }

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.Name, "admin"),
            new Claim(ClaimTypes.Role, "Administrator")
        };

        var claimsIdentity = new ClaimsIdentity(
            claims,
            CookieAuthenticationDefaults.AuthenticationScheme);

        var authProperties = new AuthenticationProperties
        {
            IsPersistent = true,
            ExpiresUtc = DateTimeOffset.UtcNow.AddDays(7),
            AllowRefresh = true
        };

        await context.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme,
            new ClaimsPrincipal(claimsIdentity),
            authProperties);

        return Results.Ok(new LoginResponse(true));
    }

    private static async Task<IResult> LogoutAsync(HttpContext context)
    {
        await context.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        return Results.Ok(new LogoutResponse(true));
    }
}
