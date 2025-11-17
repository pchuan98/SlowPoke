# 系统基础 User Stories

## US-501: 统一异常处理中间件

**作为** 开发者
**我需要** 统一处理异常
**以便** 返回一致的错误响应

### 验收标准

- [ ] 捕获所有未处理的异常
- [ ] 返回统一的错误格式
- [ ] 记录异常日志
- [ ] 区分开发环境和生产环境

### 技术要点

```csharp
// Middleware/ExceptionHandlingMiddleware.cs
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;
    private readonly IHostEnvironment _env;

    public ExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger,
        IHostEnvironment env)
    {
        _next = next;
        _logger = logger;
        _env = env;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An unhandled exception occurred");
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";

        var (statusCode, message) = exception switch
        {
            ArgumentNullException => (StatusCodes.Status400BadRequest, "Invalid input"),
            KeyNotFoundException => (StatusCodes.Status404NotFound, "Resource not found"),
            UnauthorizedAccessException => (StatusCodes.Status401Unauthorized, "Unauthorized"),
            _ => (StatusCodes.Status500InternalServerError, "Internal server error")
        };

        context.Response.StatusCode = statusCode;

        var response = new
        {
            error = message,
            details = _env.IsDevelopment() ? exception.Message : null,
            stackTrace = _env.IsDevelopment() ? exception.StackTrace : null
        };

        await context.Response.WriteAsJsonAsync(response);
    }
}
```

### 注册中间件

```csharp
// Program.cs
var app = builder.Build();

// 添加异常处理中间件
app.UseMiddleware<ExceptionHandlingMiddleware>();

// 其他中间件...
app.UseAuthentication();
app.UseAuthorization();

app.Run();
```

### 错误响应格式

**生产环境**:
```json
{
  "error": "Internal server error"
}
```

**开发环境**:
```json
{
  "error": "Internal server error",
  "details": "Object reference not set to an instance of an object.",
  "stackTrace": "   at SlowPoke.Controllers.TodoController..."
}
```

---

## US-502: 结构化日志（Serilog）

**作为** 开发者
**我需要** 结构化日志
**以便** 追踪和调试问题

### 验收标准

- [ ] 使用 Serilog 作为日志库
- [ ] 输出到控制台和文件
- [ ] 结构化日志格式
- [ ] 包含请求 ID 和时间戳

### 技术要点

```bash
# 安装 NuGet 包
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
```

```csharp
// Program.cs
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// 配置 Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.Hosting.Lifetime", LogEventLevel.Information)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "SlowPoke")
    .WriteTo.Console(
        outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj}{NewLine}{Exception}")
    .WriteTo.File(
        path: "logs/slowpoke-.log",
        rollingInterval: RollingInterval.Day,
        outputTemplate: "[{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz}] [{Level:u3}] {Message:lj}{NewLine}{Exception}")
    .CreateLogger();

try
{
    Log.Information("Starting SlowPoke application");

    builder.Host.UseSerilog();

    var app = builder.Build();

    // 添加请求日志
    app.UseSerilogRequestLogging(options =>
    {
        options.MessageTemplate = "HTTP {RequestMethod} {RequestPath} responded {StatusCode} in {Elapsed:0.0000} ms";
        options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
        {
            diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
            diagnosticContext.Set("UserAgent", httpContext.Request.Headers["User-Agent"].ToString());
        };
    });

    // 其他中间件...

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
```

### 使用日志

```csharp
public class TodoController
{
    private readonly ILogger<TodoController> _logger;

    public TodoController(ILogger<TodoController> logger)
    {
        _logger = logger;
    }

    public async Task<IResult> CreateTodo(CreateTodoRequest request)
    {
        _logger.LogInformation("Creating todo with title: {Title}", request.Title);

        try
        {
            // 创建逻辑...
            _logger.LogInformation("Todo created successfully: {TodoId}", todo.Id);
            return Results.Created($"/api/todos/{todo.Id}", todo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create todo");
            throw;
        }
    }
}
```

### 日志输出示例

```
[12:34:56 INF] Starting SlowPoke application
[12:34:57 INF] HTTP POST /api/auth/login responded 200 in 45.1234 ms
[12:35:00 INF] Creating todo with title: "实现 TODO 创建功能"
[12:35:00 INF] Todo created successfully: 3fa85f64-5717-4562-b3fc-2c963f66afa6
```

---

## US-503: API 统一响应格式

**作为** 前端开发者
**我需要** 统一的 API 响应格式
**以便** 简化错误处理

### 验收标准

- [ ] 成功响应包含数据
- [ ] 错误响应包含 error 字段
- [ ] 使用标准 HTTP 状态码
- [ ] 分页数据包含 total/page/pageSize

### 技术要点

```csharp
// Models/ApiResponse.cs
public class ApiResponse<T>
{
    public bool Success { get; set; }
    public T? Data { get; set; }
    public string? Error { get; set; }

    public static ApiResponse<T> Ok(T data)
    {
        return new ApiResponse<T>
        {
            Success = true,
            Data = data
        };
    }

    public static ApiResponse<T> Fail(string error)
    {
        return new ApiResponse<T>
        {
            Success = false,
            Error = error
        };
    }
}

public class PagedResponse<T>
{
    public int Total { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public List<T> Items { get; set; } = new();
}
```

### API 响应示例

**成功响应（单个资源）**:
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "title": "实现 TODO 创建功能",
  "createdAt": "2025-11-17T10:00:00Z"
}
```

**成功响应（列表）**:
```json
{
  "total": 100,
  "page": 1,
  "pageSize": 20,
  "items": [...]
}
```

**错误响应**:
```json
{
  "error": "Todo not found"
}
```

### 使用示例

```csharp
// 单个资源
app.MapGet("/api/todos/{id}", async (string id, IFreeSql freeSql) =>
{
    var todo = await freeSql.Select<TodoIndex>()
        .Where(t => t.Id == id)
        .FirstAsync();

    if (todo == null)
    {
        return Results.NotFound(new { error = "Todo not found" });
    }

    return Results.Ok(todo);
});

// 列表
app.MapGet("/api/todos", async (IFreeSql freeSql, int page = 1, int pageSize = 20) =>
{
    var total = await freeSql.Select<TodoIndex>().CountAsync();
    var items = await freeSql.Select<TodoIndex>()
        .Page(page, pageSize)
        .ToListAsync();

    return Results.Ok(new PagedResponse<TodoIndex>
    {
        Total = total,
        Page = page,
        PageSize = pageSize,
        Items = items
    });
});
```

---

## US-504: 配置文件管理（密码、存储路径）

**作为** 运维人员
**我需要** 通过配置文件管理系统
**以便** 灵活部署

### 验收标准

- [ ] 使用 `appsettings.json` 存储配置
- [ ] 支持环境变量覆盖
- [ ] 包含认证配置
- [ ] 包含存储路径配置

### 技术要点

```json
// appsettings.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "Auth": {
    "Password": "admin123",
    "DefaultPassword": "admin",
    "CookieName": "SlowPoke.Auth",
    "CookieExpireDays": 7
  },
  "Storage": {
    "DataDirectory": "data",
    "TodosDirectory": "data/todos",
    "DatabasePath": "data/slowpoke.db"
  },
  "AllowedHosts": "*"
}
```

```json
// appsettings.Development.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug"
    }
  },
  "Auth": {
    "Password": "dev123"
  }
}
```

```json
// appsettings.Production.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning"
    }
  }
}
```

### 读取配置

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// 读取配置
var authPassword = builder.Configuration["Auth:Password"]
    ?? builder.Configuration["Auth:DefaultPassword"]
    ?? "admin";

var dataDirectory = builder.Configuration["Storage:DataDirectory"] ?? "data";

// 注册配置服务
builder.Services.Configure<AuthOptions>(builder.Configuration.GetSection("Auth"));
builder.Services.Configure<StorageOptions>(builder.Configuration.GetSection("Storage"));
```

### 配置类

```csharp
// Options/AuthOptions.cs
public class AuthOptions
{
    public string Password { get; set; } = "admin";
    public string DefaultPassword { get; set; } = "admin";
    public string CookieName { get; set; } = "SlowPoke.Auth";
    public int CookieExpireDays { get; set; } = 7;
}

// Options/StorageOptions.cs
public class StorageOptions
{
    public string DataDirectory { get; set; } = "data";
    public string TodosDirectory { get; set; } = "data/todos";
    public string DatabasePath { get; set; } = "data/slowpoke.db";
}
```

### 使用配置

```csharp
public class TodoController
{
    private readonly StorageOptions _storageOptions;

    public TodoController(IOptions<StorageOptions> storageOptions)
    {
        _storageOptions = storageOptions.Value;
    }

    public string GetTodoFilePath(string id)
    {
        return Path.Combine(_storageOptions.TodosDirectory, $"{id}.md");
    }
}
```

### 环境变量覆盖

```bash
# Linux/Mac
export Auth__Password="production-password"
export Storage__DataDirectory="/var/slowpoke/data"

# Windows
set Auth__Password=production-password
set Storage__DataDirectory=C:\slowpoke\data

# Docker
docker run -e Auth__Password=my-password -e Storage__DataDirectory=/data slowpoke
```

### Docker Compose 示例

```yaml
version: '3.8'
services:
  slowpoke:
    image: slowpoke:latest
    environment:
      - Auth__Password=${SLOWPOKE_PASSWORD:-admin}
      - Storage__DataDirectory=/data
    volumes:
      - slowpoke-data:/data
    ports:
      - "5000:8080"

volumes:
  slowpoke-data:
```
