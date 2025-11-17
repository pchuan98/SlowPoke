namespace SlowPoke.API.Models;

public record LoginRequest(string Password);

public record LoginResponse(bool Success);

public record LogoutResponse(bool Success);
