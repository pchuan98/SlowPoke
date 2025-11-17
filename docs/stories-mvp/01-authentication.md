# 认证系统 User Stories

## US-001: POST /api/auth/login - 用户登录

**作为** 用户
**我想要** 使用密码登录系统
**以便** 访问我的 TODO 管理功能

### 验收标准

- [ ] POST 请求到 `/api/auth/login`
- [ ] 请求体包含 `password` 字段
- [ ] 返回 200 状态码表示成功
- [ ] 返回 401 状态码表示密码错误
- [ ] 成功后设置认证 Cookie

### 技术要点

```csharp
// ASP.NET Core 9 Minimal API
app.MapPost("/api/auth/login", async (LoginRequest request, IConfiguration config) =>
{
    var configPassword = config["Auth:Password"];

    if (request.Password != configPassword)
    {
        return Results.Unauthorized();
    }

    // 继续设置 Cookie...
    return Results.Ok(new { success = true });
});

public record LoginRequest(string Password);
```

### API 设计

**请求**:
```json
{
  "password": "your-password"
}
```

**响应（成功）**:
```json
{
  "success": true
}
```

**响应（失败）**:
```json
{
  "error": "Invalid password"
}
```

---

## US-002: 密码验证（配置文件中的密码）

**作为** 系统
**我需要** 从配置文件读取密码
**以便** 验证用户登录

### 验收标准

- [ ] 密码存储在 `appsettings.json` 或环境变量中
- [ ] 配置路径：`Auth:Password`
- [ ] 支持首次启动时的默认密码
- [ ] 密码明文存储（MVP 阶段）

### 技术要点

```json
// appsettings.json
{
  "Auth": {
    "Password": "admin123",
    "DefaultPassword": "admin"
  }
}
```

```csharp
// 读取配置
var password = builder.Configuration["Auth:Password"]
    ?? builder.Configuration["Auth:DefaultPassword"];
```

---

## US-003: 设置 Cookie（HttpOnly/Secure/SameSite）

**作为** 系统
**我需要** 设置安全的认证 Cookie
**以便** 保护用户会话安全

### 验收标准

- [ ] Cookie 名称：`SlowPoke.Auth`
- [ ] `HttpOnly = true`（防止 XSS）
- [ ] `Secure = true`（生产环境，HTTPS only）
- [ ] `SameSite = Strict`（防止 CSRF）
- [ ] Cookie 路径：`/`

### 技术要点

```csharp
// ASP.NET Core 9 Cookie Authentication
using Microsoft.AspNetCore.Authentication.Cookies;
using System.Security.Claims;

// 登录时设置 Cookie
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
    ExpiresUtc = DateTimeOffset.UtcNow.AddDays(7)
};

await context.SignInAsync(
    CookieAuthenticationDefaults.AuthenticationScheme,
    new ClaimsPrincipal(claimsIdentity),
    authProperties);
```

### Cookie 配置

```csharp
// Program.cs 配置
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.Cookie.Name = "SlowPoke.Auth";
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest; // 生产环境改为 Always
        options.Cookie.SameSite = SameSiteMode.Strict;
        options.LoginPath = "/login";
        options.ExpireTimeSpan = TimeSpan.FromDays(7);
    });
```

---

## US-004: Cookie 有效期 7 天

**作为** 用户
**我希望** 登录状态保持 7 天
**以便** 不需要频繁重新登录

### 验收标准

- [ ] Cookie 有效期设置为 7 天
- [ ] 使用 `IsPersistent = true` 持久化 Cookie
- [ ] 过期后自动跳转登录页

### 技术要点

```csharp
var authProperties = new AuthenticationProperties
{
    IsPersistent = true,
    ExpiresUtc = DateTimeOffset.UtcNow.AddDays(7),
    AllowRefresh = true
};
```

---

## US-005: POST /api/auth/logout - 用户登出

**作为** 用户
**我想要** 安全登出系统
**以便** 结束当前会话

### 验收标准

- [ ] POST 请求到 `/api/auth/logout`
- [ ] 清除认证 Cookie
- [ ] 返回 200 状态码

### 技术要点

```csharp
app.MapPost("/api/auth/logout", async (HttpContext context) =>
{
    await context.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
    return Results.Ok(new { success = true });
})
.RequireAuthorization(); // 需要认证才能登出
```

---

## US-006: 清除 Cookie

**作为** 系统
**我需要** 在登出时清除 Cookie
**以便** 确保会话完全终止

### 验收标准

- [ ] 调用 `SignOutAsync` 清除 Cookie
- [ ] 客户端收到响应后清除本地状态
- [ ] Cookie 立即失效

### 技术要点

```csharp
// 服务端
await context.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

// 客户端清除状态（React）
const logout = async () => {
  await axios.post('/api/auth/logout');
  // 清除 Zustand 状态
  useAuthStore.getState().clearAuth();
  navigate('/login');
};
```

---

## US-007: 认证中间件（拦截所有 API 除登录接口）

**作为** 系统
**我需要** 保护所有 API 端点
**以便** 只有认证用户可以访问

### 验收标准

- [ ] 所有 `/api/*` 端点需要认证
- [ ] `/api/auth/login` 例外（允许匿名）
- [ ] 未认证请求返回 401
- [ ] 使用 ASP.NET Core 认证中间件

### 技术要点

```csharp
// Program.cs
var app = builder.Build();

// 添加认证和授权中间件
app.UseAuthentication();
app.UseAuthorization();

// 登录端点（匿名访问）
app.MapPost("/api/auth/login", async (LoginRequest request) => { ... })
   .AllowAnonymous();

// 需要认证的端点
app.MapGet("/api/todos", async (IFreeSql freeSql) => { ... })
   .RequireAuthorization();

// 或者使用全局策略
app.MapGroup("/api")
   .RequireAuthorization()
   .MapGet("/todos", async (IFreeSql freeSql) => { ... });
```

---

## US-008: 未认证时返回 401

**作为** 系统
**我需要** 对未认证请求返回 401
**以便** 客户端知道需要登录

### 验收标准

- [ ] 未认证请求返回 `401 Unauthorized`
- [ ] 响应包含错误信息
- [ ] 客户端收到 401 后跳转登录页

### 技术要点

```csharp
// Cookie 配置
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.Events.OnRedirectToLogin = context =>
        {
            // API 请求返回 401 而不是重定向
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            return Task.CompletedTask;
        };
    });
```

```typescript
// Axios 拦截器（React）
axios.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      // 跳转登录页
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

---

## US-009: 登录页面（密码输入框）

**作为** 用户
**我需要** 一个登录页面
**以便** 输入密码进行认证

### 验收标准

- [ ] 页面路由：`/login`
- [ ] 包含密码输入框（type="password"）
- [ ] 包含登录按钮
- [ ] 显示错误提示（密码错误时）
- [ ] 使用 shadcn/ui 组件

### 技术要点

```tsx
// LoginPage.tsx
import { useState } from 'react';
import { useNavigate } from 'react-router'; // React Router v7
import axios from 'axios';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { useToast } from '@/hooks/use-toast';

export default function LoginPage() {
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { toast } = useToast();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      await axios.post('/api/auth/login', { password });
      toast({
        title: '登录成功',
        description: '欢迎回来！',
      });
      navigate('/');
    } catch (error) {
      toast({
        variant: 'destructive',
        title: '登录失败',
        description: '密码错误，请重试',
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center">
      <form onSubmit={handleLogin} className="w-full max-w-sm space-y-4">
        <h1 className="text-2xl font-bold">SlowPoke 登录</h1>
        <Input
          type="password"
          placeholder="请输入密码"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        <Button type="submit" className="w-full" disabled={loading}>
          {loading ? '登录中...' : '登录'}
        </Button>
      </form>
    </div>
  );
}
```

---

## US-010: 登录成功跳转主页

**作为** 用户
**我希望** 登录成功后自动跳转到主页
**以便** 开始使用 TODO 功能

### 验收标准

- [ ] 登录成功后跳转到 `/`
- [ ] 使用 React Router v7 的 `useNavigate`
- [ ] 跳转前显示成功提示

### 技术要点

```tsx
import { useNavigate } from 'react-router'; // React Router v7

const navigate = useNavigate();

const handleLogin = async () => {
  try {
    await axios.post('/api/auth/login', { password });
    navigate('/'); // 跳转到主页
  } catch (error) {
    // 错误处理
  }
};
```

---

## US-011: 登录失败显示错误提示

**作为** 用户
**我需要** 看到登录失败的提示
**以便** 知道密码错误并重试

### 验收标准

- [ ] 显示错误提示（使用 shadcn/ui Toast）
- [ ] 提示内容："密码错误，请重试"
- [ ] 不清空输入框（方便用户修改）

### 技术要点

```tsx
import { useToast } from '@/hooks/use-toast';

const { toast } = useToast();

try {
  await axios.post('/api/auth/login', { password });
} catch (error) {
  toast({
    variant: 'destructive',
    title: '登录失败',
    description: '密码错误，请重试',
  });
}
```

---

## US-012: 登出按钮

**作为** 用户
**我需要** 一个登出按钮
**以便** 退出当前会话

### 验收标准

- [ ] 登出按钮位于页面右上角
- [ ] 点击后调用 `/api/auth/logout`
- [ ] 登出成功后跳转到 `/login`
- [ ] 清除客户端状态

### 技术要点

```tsx
// Logout Button Component
import { useNavigate } from 'react-router';
import { Button } from '@/components/ui/button';
import { LogOut } from 'lucide-react';
import axios from 'axios';

export function LogoutButton() {
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await axios.post('/api/auth/logout');
      navigate('/login');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  return (
    <Button variant="ghost" onClick={handleLogout}>
      <LogOut className="mr-2 h-4 w-4" />
      登出
    </Button>
  );
}
```
