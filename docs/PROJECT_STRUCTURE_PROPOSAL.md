# SlowPoke 项目结构建议（基于 Plane 命名规范）

参考 Plane 开源项目的实际目录命名和组织方式

---

## 一、完整项目结构（apps 完全展开）

```
SlowPoke/
├── apps/
│   ├── web/                                # React Web 应用
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── ui/                       # shadcn/ui 基础组件
│   │   │   │   │   ├── button.tsx
│   │   │   │   │   ├── input.tsx
│   │   │   │   │   ├── card.tsx
│   │   │   │   │   ├── badge.tsx
│   │   │   │   │   ├── dialog.tsx
│   │   │   │   │   ├── alert-dialog.tsx
│   │   │   │   │   ├── select.tsx
│   │   │   │   │   ├── label.tsx
│   │   │   │   │   ├── toast.tsx
│   │   │   │   │   └── toaster.tsx
│   │   │   │   │
│   │   │   │   ├── common/                   # 通用组件
│   │   │   │   │   ├── Header.tsx
│   │   │   │   │   ├── Loading.tsx
│   │   │   │   │   ├── ErrorBoundary.tsx
│   │   │   │   │   └── EmptyState.tsx
│   │   │   │   │
│   │   │   │   ├── todo/                     # TODO 相关组件
│   │   │   │   │   ├── TodoCard.tsx
│   │   │   │   │   ├── TodoList.tsx
│   │   │   │   │   ├── TodoFieldsForm.tsx
│   │   │   │   │   ├── DeleteTodoDialog.tsx
│   │   │   │   │   └── SortSelector.tsx
│   │   │   │   │
│   │   │   │   ├── editor/                   # 编辑器组件
│   │   │   │   │   └── MarkdownEditor.tsx
│   │   │   │   │
│   │   │   │   └── layouts/                  # 布局组件
│   │   │   │       ├── ProtectedLayout.tsx
│   │   │   │       └── PublicLayout.tsx
│   │   │   │
│   │   │   ├── pages/                      # 页面组件
│   │   │   │   ├── LoginPage.tsx
│   │   │   │   ├── HomePage.tsx
│   │   │   │   └── TodoEditorPage.tsx
│   │   │   │
│   │   │   ├── services/                   # API 服务层
│   │   │   │   ├── api.ts                    # Axios 配置
│   │   │   │   ├── auth.service.ts           # 认证 API
│   │   │   │   └── todo.service.ts           # TODO API
│   │   │   │
│   │   │   ├── stores/                     # Zustand 状态管理
│   │   │   │   ├── authStore.ts
│   │   │   │   └── todoStore.ts
│   │   │   │
│   │   │   ├── types/                      # TypeScript 类型
│   │   │   │   ├── todo.ts
│   │   │   │   ├── auth.ts
│   │   │   │   └── api.ts
│   │   │   │
│   │   │   ├── hooks/                      # 自定义 Hooks
│   │   │   │   ├── useAuth.ts
│   │   │   │   ├── useTodos.ts
│   │   │   │   └── use-toast.ts
│   │   │   │
│   │   │   ├── utils/                      # 工具函数
│   │   │   │   ├── format.ts
│   │   │   │   ├── validation.ts
│   │   │   │   └── cn.ts                     # className 工具
│   │   │   │
│   │   │   ├── lib/                        # 第三方库配置
│   │   │   │   └── utils.ts
│   │   │   │
│   │   │   ├── routes/                     # 路由配置
│   │   │   │   └── index.tsx
│   │   │   │
│   │   │   ├── App.tsx                     # 应用根组件
│   │   │   ├── main.tsx                    # 应用入口
│   │   │   └── index.css                   # 全局样式
│   │   │
│   │   ├── public/                         # 静态资源
│   │   │   └── favicon.ico
│   │   │
│   │   ├── index.html
│   │   ├── vite.config.ts
│   │   ├── tailwind.config.js
│   │   ├── postcss.config.js
│   │   ├── tsconfig.json
│   │   ├── tsconfig.node.json
│   │   ├── components.json                 # shadcn/ui 配置
│   │   ├── .eslintrc.cjs
│   │   ├── .prettierrc
│   │   ├── .gitignore
│   │   └── package.json
│   │
│   └── api/                                # ASP.NET Core API
│       ├── Endpoints/                        # Minimal API 端点
│       │   ├── AuthEndpoints.cs
│       │   ├── TodoEndpoints.cs
│       │   └── HealthEndpoints.cs
│       │
│       ├── Middleware/                       # 中间件
│       │   ├── ExceptionHandlingMiddleware.cs
│       │   └── RequestLoggingMiddleware.cs
│       │
│       ├── Extensions/                       # 扩展方法
│       │   ├── ServiceCollectionExtensions.cs
│       │   └── ApplicationBuilderExtensions.cs
│       │
│       ├── Entities/                         # 实体模型
│       │   └── TodoIndex.cs
│       │
│       ├── DTOs/                            # 数据传输对象
│       │   ├── Requests/
│       │   │   ├── CreateTodoRequest.cs
│       │   │   ├── UpdateTodoRequest.cs
│       │   │   └── LoginRequest.cs
│       │   │
│       │   └── Responses/
│       │       ├── TodoResponse.cs
│       │       ├── TodoListResponse.cs
│       │       └── PagedResponse.cs
│       │
│       ├── Repositories/                     # 数据访问
│       │   ├── ITodoRepository.cs
│       │   └── TodoRepository.cs
│       │
│       ├── Services/                         # 业务服务
│       │   ├── ITodoFileService.cs
│       │   ├── TodoFileService.cs
│       │   ├── ITodoSyncService.cs
│       │   ├── TodoSyncService.cs
│       │   ├── IAuthService.cs
│       │   └── AuthService.cs
│       │
│       ├── Exceptions/                       # 自定义异常
│       │   ├── TodoNotFoundException.cs
│       │   └── InvalidTodoFormatException.cs
│       │
│       ├── Properties/
│       │   └── launchSettings.json
│       │
│       ├── Program.cs
│       ├── appsettings.json
│       ├── appsettings.Development.json
│       ├── .gitignore
│       └── SlowPoke.Api.csproj              # 项目文件
│
├── packages/                               # 共享包（可选）
│   └── types/
│       ├── todo.ts
│       ├── api.ts
│       └── package.json
│
├── deployments/                            # 部署配置
│   ├── docker/
│   │   ├── Dockerfile.web
│   │   ├── Dockerfile.api
│   │   └── Dockerfile.aio
│   │
│   ├── docker-compose.yml
│   ├── docker-compose.dev.yml
│   └── .env.example
│
├── scripts/                                # 构建和开发脚本
│   ├── dev.sh
│   ├── build.sh
│   └── clean.sh
│
├── docs/                                   # 文档
│   ├── prd-mvp/
│   ├── stories-mvp/
│   └── PROJECT_STRUCTURE_PROPOSAL.md
│
├── .editorconfig
├── .gitignore
├── Directory.Build.props
├── LICENSE
├── README.md
└── SlowPoke.sln                            # .NET 解决方案文件
```

---

## 二、apps/web 详细说明

### 2.1 目录职责

| 目录 | 职责 |
|------|------|
| `components/ui/` | shadcn/ui 基础组件（从官方 CLI 生成） |
| `components/common/` | 项目通用组件（Header、Loading 等） |
| `components/todo/` | TODO 功能组件（TodoCard、TodoList 等） |
| `components/editor/` | Markdown 编辑器封装 |
| `components/layouts/` | 布局组件（ProtectedLayout、PublicLayout） |
| `pages/` | 页面级组件（LoginPage、HomePage 等） |
| `services/` | API 调用封装（auth.service、todo.service） |
| `stores/` | Zustand 状态管理（authStore、todoStore） |
| `types/` | TypeScript 类型定义 |
| `hooks/` | 自定义 React Hooks |
| `utils/` | 工具函数（format、validation 等） |
| `lib/` | 第三方库配置 |
| `routes/` | React Router v7 路由配置 |

---

## 三、apps/api 详细说明

### 3.1 目录职责

| 目录 | 职责 |
|------|------|
| `Endpoints/` | Minimal API 端点定义（AuthEndpoints、TodoEndpoints） |
| `Middleware/` | ASP.NET Core 中间件（异常处理、日志） |
| `Extensions/` | 扩展方法（服务注册、中间件配置） |
| `Entities/` | 数据库实体模型（TodoIndex） |
| `DTOs/` | 数据传输对象（Requests、Responses） |
| `Repositories/` | 数据访问层（TodoRepository + FreeSql） |
| `Services/` | 业务服务层（TodoFileService、TodoSyncService） |
| `Exceptions/` | 自定义异常类 |

### 3.2 关键设计

**单项目架构**：
- 所有代码在一个 `SlowPoke.Api.csproj` 项目中
- 使用命名空间区分层次：
  - `SlowPoke.Api.Endpoints`
  - `SlowPoke.Api.Services`
  - `SlowPoke.Api.Repositories`
  - `SlowPoke.Api.Entities`

**优势**：
- ✅ 结构简单，易于理解
- ✅ 适合小型项目和快速迭代
- ✅ 减少项目引用的复杂度
- ✅ 与 Plane 的 apps/api 风格一致

---

## 四、配置文件详细说明

### 4.1 apps/web/vite.config.ts

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
})
```

### 4.2 apps/web/components.json（shadcn/ui）

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.js",
    "css": "src/index.css",
    "baseColor": "slate",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils"
  }
}
```

### 4.3 apps/api/appsettings.json

```json
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

### 4.4 apps/api/SlowPoke.Api.csproj

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="FreeSql" Version="3.5.215" />
    <PackageReference Include="FreeSql.Provider.Sqlite" Version="3.5.215" />
    <PackageReference Include="Serilog.AspNetCore" Version="8.0.1" />
    <PackageReference Include="Serilog.Sinks.Console" Version="5.0.1" />
    <PackageReference Include="Serilog.Sinks.File" Version="5.0.0" />
  </ItemGroup>

</Project>
```

---

## 五、项目创建步骤

### 步骤 1: 创建目录结构

```bash
# 创建 web 应用目录
mkdir -p apps/web/src/{components/{ui,common,todo,editor,layouts},pages,services,stores,types,hooks,utils,lib,routes}
mkdir -p apps/web/public

# 创建 api 应用目录
mkdir -p apps/api/{Endpoints,Middleware,Extensions,Entities,DTOs/{Requests,Responses},Repositories,Services,Exceptions,Properties}

# 创建其他目录
mkdir -p packages/types
mkdir -p deployments/docker
mkdir -p scripts
```

### 步骤 2: 创建 React 项目（apps/web）

```bash
# 使用 Vite 创建
npm create vite@latest apps/web -- --template react-ts

# 进入目录
cd apps/web

# 安装依赖
npm install

# 安装核心库
npm install react-router@latest zustand@latest axios @uiw/react-md-editor@latest date-fns

# 安装 Tailwind CSS
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# 初始化 shadcn/ui
npx shadcn-ui@latest init

# 安装开发工具
npm install -D @types/node eslint prettier

cd ../..
```

### 步骤 3: 创建 .NET 项目（apps/api）

```bash
# 创建解决方案
dotnet new sln -n SlowPoke

# 创建 API 项目
dotnet new web -n SlowPoke.Api -o apps/api

# 添加到解决方案
dotnet sln add apps/api/SlowPoke.Api.csproj

# 安装依赖
cd apps/api
dotnet add package FreeSql
dotnet add package FreeSql.Provider.Sqlite
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
dotnet add package Microsoft.AspNetCore.Authentication.Cookies

cd ../..
```

### 步骤 4: 清理默认生成的文件

```bash
# 删除 web 默认文件（保留后面会手动创建）
rm -rf apps/web/src/*

# 删除 api 默认文件
rm -f apps/api/Controllers/*
rm -f apps/api/WeatherForecast.cs
```

---

## 六、命名空间组织

### apps/api 的命名空间

```csharp
// Endpoints/
namespace SlowPoke.Api.Endpoints;

// Services/
namespace SlowPoke.Api.Services;

// Repositories/
namespace SlowPoke.Api.Repositories;

// Entities/
namespace SlowPoke.Api.Entities;

// DTOs/
namespace SlowPoke.Api.DTOs.Requests;
namespace SlowPoke.Api.DTOs.Responses;

// Middleware/
namespace SlowPoke.Api.Middleware;

// Extensions/
namespace SlowPoke.Api.Extensions;

// Exceptions/
namespace SlowPoke.Api.Exceptions;
```

---

## 七、与多项目方案的对比

### ❌ 之前的多项目方案

```
apps/api/
├── SlowPoke.Api/
├── SlowPoke.Core/
├── SlowPoke.Data/
└── SlowPoke.Services/
```

**缺点**：
- 过度工程化
- 项目引用复杂
- 不符合 Plane 的简洁风格

### ✅ 现在的单项目方案

```
apps/api/
├── Endpoints/
├── Services/
├── Repositories/
├── Entities/
└── ...
```

**优点**：
- 结构简洁
- 易于理解和维护
- 符合 Plane 风格
- 适合 MVP 快速迭代

---

## 八、开发脚本

### scripts/dev.sh

```bash
#!/bin/bash

echo "Starting SlowPoke development environment..."

# 启动 API
cd apps/api
dotnet run &
API_PID=$!

# 启动 Web
cd ../web
npm run dev &
WEB_PID=$!

# 等待进程
wait $API_PID $WEB_PID
```

### scripts/build.sh

```bash
#!/bin/bash

echo "Building SlowPoke..."

# 构建 API
cd apps/api
dotnet publish -c Release -o ../../dist/api

# 构建 Web
cd ../web
npm run build
mv dist ../../dist/web

echo "Build complete! Output in dist/"
```

---

## 九、下一步

**这个单项目结构是否符合预期？**

如果确认，我将立即：
1. ✅ 创建所有目录
2. ✅ 生成项目文件
3. ✅ 创建基础代码模板
4. ✅ 配置所有依赖
