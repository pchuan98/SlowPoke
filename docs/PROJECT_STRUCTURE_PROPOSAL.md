# SlowPoke 项目结构建议

基于 Plane 开源项目的经验，结合 SlowPoke 的需求（单用户、本地优先、ASP.NET Core + React）

---

## 一、整体项目结构（参考 Plane 的 Monorepo）

```
SlowPoke/
├── src/
│   ├── backend/              # ASP.NET Core 后端
│   │   ├── SlowPoke.Api/        # Web API 项目
│   │   ├── SlowPoke.Core/       # 核心业务逻辑
│   │   ├── SlowPoke.Data/       # 数据访问层
│   │   └── SlowPoke.Services/   # 服务层
│   │
│   └── frontend/             # React 前端
│       ├── src/
│       │   ├── components/      # UI 组件
│       │   ├── pages/           # 页面组件
│       │   ├── services/        # API 服务
│       │   ├── stores/          # Zustand 状态管理
│       │   ├── types/           # TypeScript 类型
│       │   └── utils/           # 工具函数
│       ├── public/
│       └── package.json
│
├── deployments/              # 部署配置（学习 Plane）
│   ├── docker/
│   │   ├── Dockerfile.backend
│   │   └── Dockerfile.frontend
│   ├── docker-compose.yml
│   └── docker-compose.dev.yml
│
├── docs/                     # 文档（已有）
├── scripts/                  # 构建脚本
├── tests/                    # 测试（后续添加）
├── .editorconfig
├── .gitignore
├── Directory.Build.props
├── LICENSE
├── README.md
└── SlowPoke.sln              # .NET 解决方案文件
```

---

## 二、后端项目结构（ASP.NET Core）

### 2.1 SlowPoke.Api（Web API 项目）

```
SlowPoke.Api/
├── Controllers/              # 不使用，使用 Minimal API
├── Endpoints/                # Minimal API 端点定义
│   ├── AuthEndpoints.cs         # 认证相关端点
│   ├── TodoEndpoints.cs         # TODO CRUD 端点
│   └── HealthEndpoints.cs       # 健康检查
│
├── Middleware/               # 中间件
│   ├── ExceptionHandlingMiddleware.cs
│   └── RequestLoggingMiddleware.cs
│
├── Extensions/               # 扩展方法
│   ├── ServiceCollectionExtensions.cs
│   └── ApplicationBuilderExtensions.cs
│
├── Program.cs                # 应用入口
├── appsettings.json
├── appsettings.Development.json
└── SlowPoke.Api.csproj
```

### 2.2 SlowPoke.Core（核心业务逻辑）

```
SlowPoke.Core/
├── Entities/                 # 实体模型
│   └── TodoIndex.cs             # TODO 索引实体
│
├── Interfaces/               # 接口定义
│   ├── IRepository.cs
│   ├── ITodoRepository.cs
│   ├── ITodoFileService.cs
│   └── ITodoSyncService.cs
│
├── DTOs/                     # 数据传输对象
│   ├── Requests/
│   │   ├── CreateTodoRequest.cs
│   │   ├── UpdateTodoRequest.cs
│   │   └── LoginRequest.cs
│   └── Responses/
│       ├── TodoResponse.cs
│       ├── TodoListResponse.cs
│       └── PagedResponse.cs
│
├── Exceptions/               # 自定义异常
│   ├── TodoNotFoundException.cs
│   └── InvalidTodoFormatException.cs
│
└── SlowPoke.Core.csproj
```

### 2.3 SlowPoke.Data（数据访问层）

```
SlowPoke.Data/
├── Repositories/             # 仓储实现
│   ├── BaseRepository.cs
│   └── TodoRepository.cs
│
├── Context/                  # 数据库上下文（FreeSql）
│   └── SlowPokeDbContext.cs
│
├── Configurations/           # 数据库配置
│   └── DatabaseConfiguration.cs
│
└── SlowPoke.Data.csproj
```

### 2.4 SlowPoke.Services（服务层）

```
SlowPoke.Services/
├── TodoFileService.cs        # Markdown 文件操作
├── TodoSyncService.cs        # 文件与数据库同步
├── AuthService.cs            # 认证服务
└── SlowPoke.Services.csproj
```

---

## 三、前端项目结构（React + TypeScript）

### 3.1 参考 Plane 的模块化设计

```
frontend/
├── src/
│   ├── components/           # UI 组件（参考 Plane）
│   │   ├── ui/                  # shadcn/ui 基础组件
│   │   │   ├── button.tsx
│   │   │   ├── input.tsx
│   │   │   ├── card.tsx
│   │   │   └── ...
│   │   │
│   │   ├── common/              # 通用组件
│   │   │   ├── Header.tsx
│   │   │   ├── Loading.tsx
│   │   │   └── ErrorBoundary.tsx
│   │   │
│   │   ├── todo/                # TODO 相关组件
│   │   │   ├── TodoCard.tsx
│   │   │   ├── TodoList.tsx
│   │   │   ├── TodoFieldsForm.tsx
│   │   │   └── DeleteTodoDialog.tsx
│   │   │
│   │   └── editor/              # 编辑器组件
│   │       └── MarkdownEditor.tsx
│   │
│   ├── pages/                # 页面组件（参考 Plane 的 pages）
│   │   ├── LoginPage.tsx
│   │   ├── HomePage.tsx
│   │   └── TodoEditorPage.tsx
│   │
│   ├── services/             # API 服务层（参考 Plane）
│   │   ├── api.ts               # Axios 配置
│   │   ├── auth.service.ts      # 认证 API
│   │   └── todo.service.ts      # TODO API
│   │
│   ├── stores/               # Zustand 状态管理
│   │   ├── authStore.ts
│   │   └── todoStore.ts
│   │
│   ├── types/                # TypeScript 类型定义
│   │   ├── todo.ts
│   │   ├── auth.ts
│   │   └── api.ts
│   │
│   ├── hooks/                # 自定义 Hooks
│   │   ├── useAuth.ts
│   │   ├── useTodos.ts
│   │   └── use-toast.ts
│   │
│   ├── utils/                # 工具函数
│   │   ├── format.ts
│   │   └── validation.ts
│   │
│   ├── routes/               # 路由配置（React Router v7）
│   │   └── index.tsx
│   │
│   ├── App.tsx               # 应用根组件
│   ├── main.tsx              # 应用入口
│   └── index.css             # 全局样式
│
├── public/
├── index.html
├── vite.config.ts            # Vite 配置
├── tailwind.config.js        # Tailwind 配置
├── tsconfig.json
└── package.json
```

---

## 四、API 端点组织（参考 Plane 的 REST API 设计）

### 4.1 端点分组策略

Plane 使用 **功能模块** 分组 API，我们采用类似方式：

```csharp
// Program.cs - 使用 Minimal API + Route Groups

var app = builder.Build();

// 1. 认证端点组
var authGroup = app.MapGroup("/api/auth")
    .WithTags("Authentication");

authGroup.MapPost("/login", AuthEndpoints.Login)
    .AllowAnonymous();

authGroup.MapPost("/logout", AuthEndpoints.Logout)
    .RequireAuthorization();

// 2. TODO 端点组
var todoGroup = app.MapGroup("/api/todos")
    .WithTags("Todos")
    .RequireAuthorization();

todoGroup.MapGet("/", TodoEndpoints.GetTodos);
todoGroup.MapGet("/{id}", TodoEndpoints.GetTodoById);
todoGroup.MapPost("/", TodoEndpoints.CreateTodo);
todoGroup.MapPatch("/{id}", TodoEndpoints.UpdateTodo);
todoGroup.MapDelete("/{id}", TodoEndpoints.DeleteTodo);

// 3. 系统端点组
var systemGroup = app.MapGroup("/api/system")
    .WithTags("System")
    .AllowAnonymous();

systemGroup.MapGet("/health", HealthEndpoints.GetHealth);
systemGroup.MapGet("/version", HealthEndpoints.GetVersion);

app.Run();
```

### 4.2 端点文件组织（学习 Plane 的模块化）

```
Endpoints/
├── AuthEndpoints.cs          # 认证相关
│   ├── Login()
│   └── Logout()
│
├── TodoEndpoints.cs          # TODO 相关
│   ├── GetTodos()
│   ├── GetTodoById()
│   ├── CreateTodo()
│   ├── UpdateTodo()
│   └── DeleteTodo()
│
└── HealthEndpoints.cs        # 系统健康
    ├── GetHealth()
    └── GetVersion()
```

### 4.3 端点实现示例

```csharp
// Endpoints/TodoEndpoints.cs
public static class TodoEndpoints
{
    public static async Task<IResult> GetTodos(
        IFreeSql freeSql,
        int page = 1,
        int pageSize = 20,
        string? sortBy = "createdAt",
        string? sortOrder = "desc")
    {
        // 实现...
    }

    public static async Task<IResult> CreateTodo(
        CreateTodoRequest request,
        ITodoRepository todoRepository,
        ITodoFileService fileService)
    {
        // 实现...
    }

    // 其他端点...
}
```

---

## 五、前端界面划分（参考 Plane 的 UI 架构）

### 5.1 路由结构

```typescript
// routes/index.tsx
import { createBrowserRouter } from 'react-router';

export const router = createBrowserRouter([
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    path: '/',
    element: <ProtectedLayout />, // 需要认证的布局
    children: [
      {
        index: true,
        element: <HomePage />, // List 视图
      },
      {
        path: 'todos/new',
        element: <TodoEditorPage />,
      },
      {
        path: 'todos/:id',
        element: <TodoEditorPage />,
      },
    ],
  },
]);
```

### 5.2 布局组件（学习 Plane）

```typescript
// components/layouts/ProtectedLayout.tsx
export function ProtectedLayout() {
  const { isAuthenticated } = useAuthStore();

  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      <main className="container mx-auto p-4">
        <Outlet />
      </main>
    </div>
  );
}
```

### 5.3 页面职责划分

| 页面 | 路由 | 职责 |
|------|------|------|
| **LoginPage** | `/login` | 用户登录 |
| **HomePage** | `/` | TODO 列表展示 + 排序 + 删除 |
| **TodoEditorPage** | `/todos/new` | 创建新 TODO |
| **TodoEditorPage** | `/todos/:id` | 编辑现有 TODO |

---

## 六、关键设计决策（对比 Plane）

### Plane 的架构
- **Monorepo**: 使用 pnpm workspaces 管理多个包
- **微服务**: 前端、后端、Worker、Proxy 等多个服务
- **复杂度高**: 适合大型团队和多用户场景

### SlowPoke 的架构
- **简化 Monorepo**: 单一后端 + 单一前端
- **单体应用**: 所有功能在一个容器中
- **低复杂度**: 适合单用户和快速迭代

---

## 七、推荐的项目创建顺序

1. **创建 .NET 解决方案和项目**
   ```bash
   # 创建解决方案
   dotnet new sln -n SlowPoke

   # 创建后端项目
   dotnet new web -n SlowPoke.Api -o src/backend/SlowPoke.Api
   dotnet new classlib -n SlowPoke.Core -o src/backend/SlowPoke.Core
   dotnet new classlib -n SlowPoke.Data -o src/backend/SlowPoke.Data
   dotnet new classlib -n SlowPoke.Services -o src/backend/SlowPoke.Services

   # 添加项目到解决方案
   dotnet sln add src/backend/SlowPoke.Api
   dotnet sln add src/backend/SlowPoke.Core
   dotnet sln add src/backend/SlowPoke.Data
   dotnet sln add src/backend/SlowPoke.Services
   ```

2. **创建前端项目**
   ```bash
   # 使用 Vite + React + TypeScript
   npm create vite@latest src/frontend -- --template react-ts
   ```

3. **设置项目引用**
   ```bash
   cd src/backend/SlowPoke.Api
   dotnet add reference ../SlowPoke.Core
   dotnet add reference ../SlowPoke.Data
   dotnet add reference ../SlowPoke.Services
   ```

4. **安装依赖**
   ```bash
   # 后端
   dotnet add package FreeSql
   dotnet add package FreeSql.Provider.Sqlite
   dotnet add package Serilog.AspNetCore

   # 前端
   cd src/frontend
   npm install react-router@latest
   npm install zustand@latest
   npm install axios
   npm install @uiw/react-md-editor@latest
   ```

---

## 八、与 Plane 的差异总结

| 维度 | Plane | SlowPoke |
|------|-------|----------|
| **后端** | Django (Python) | ASP.NET Core (C#) |
| **前端** | Next.js | React + Vite |
| **数据库** | PostgreSQL | SQLite |
| **部署** | 多容器微服务 | 单容器单体应用 |
| **用户模式** | 多用户 SaaS | 单用户本地优先 |
| **复杂度** | 高（企业级） | 低（MVP 快速迭代） |
| **文件存储** | MinIO | 本地 Markdown 文件 |

---

## 九、下一步建议

**请审核以上结构后，我将：**

1. ✅ 创建所有项目文件和目录
2. ✅ 配置项目引用和依赖
3. ✅ 生成基础代码模板（Entity、Interface、DTO 等）
4. ✅ 配置 Docker 和 Docker Compose
5. ✅ 提供开发环境启动脚本

**需要调整的地方请告诉我！**
