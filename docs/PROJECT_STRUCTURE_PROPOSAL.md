# SlowPoke 项目结构建议（基于 Plane 命名规范）

参考 Plane 开源项目的实际目录命名和组织方式

---

## 一、Plane 的实际目录结构

```
plane/
├── apps/                     # 应用程序
│   ├── web/                    # 主 Web 界面（Next.js）
│   ├── admin/                  # 管理界面
│   ├── space/                  # 公共空间
│   └── api/                    # API 服务（Django）
│
├── packages/                 # 共享包
│   ├── editor/                 # 编辑器组件
│   ├── types/                  # TypeScript 类型
│   └── utils/                  # 工具函数
│
└── deployments/              # 部署配置
    ├── docker/
    └── kubernetes/
```

**关键观察**：
- ✅ 使用 `apps/` 而不是 `frontend/` 或 `backend/`
- ✅ 每个应用按功能命名：`web`、`api`、`admin`
- ✅ 共享代码放在 `packages/`
- ✅ 部署配置独立在 `deployments/`

---

## 二、SlowPoke 的目录结构（参考 Plane）

```
SlowPoke/
├── apps/                     # 应用程序
│   ├── web/                    # React 前端应用
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── pages/
│   │   │   ├── services/
│   │   │   ├── stores/
│   │   │   ├── types/
│   │   │   └── utils/
│   │   ├── public/
│   │   ├── index.html
│   │   ├── vite.config.ts
│   │   └── package.json
│   │
│   └── api/                    # ASP.NET Core API
│       ├── SlowPoke.Api/         # Web API 项目
│       ├── SlowPoke.Core/        # 核心业务逻辑
│       ├── SlowPoke.Data/        # 数据访问层
│       └── SlowPoke.Services/    # 服务层
│
├── packages/                 # 共享包（可选，初期可能不需要）
│   └── types/                  # 共享的 TypeScript 类型定义
│
├── deployments/              # 部署配置
│   ├── docker/
│   │   ├── Dockerfile.web
│   │   └── Dockerfile.api
│   ├── docker-compose.yml
│   └── docker-compose.dev.yml
│
├── docs/                     # 文档
├── scripts/                  # 构建和开发脚本
├── .editorconfig
├── .gitignore
├── Directory.Build.props
├── LICENSE
├── README.md
└── SlowPoke.sln              # .NET 解决方案
```

---

## 三、apps/web/ 详细结构（React 应用）

```
apps/web/
├── src/
│   ├── components/           # UI 组件
│   │   ├── ui/                 # shadcn/ui 基础组件
│   │   │   ├── button.tsx
│   │   │   ├── input.tsx
│   │   │   ├── card.tsx
│   │   │   └── ...
│   │   │
│   │   ├── common/             # 通用组件
│   │   │   ├── Header.tsx
│   │   │   ├── Loading.tsx
│   │   │   └── ErrorBoundary.tsx
│   │   │
│   │   ├── todo/               # TODO 相关组件
│   │   │   ├── TodoCard.tsx
│   │   │   ├── TodoList.tsx
│   │   │   ├── TodoFieldsForm.tsx
│   │   │   └── DeleteTodoDialog.tsx
│   │   │
│   │   ├── editor/             # 编辑器组件
│   │   │   └── MarkdownEditor.tsx
│   │   │
│   │   └── layouts/            # 布局组件
│   │       ├── ProtectedLayout.tsx
│   │       └── PublicLayout.tsx
│   │
│   ├── pages/                # 页面组件
│   │   ├── LoginPage.tsx
│   │   ├── HomePage.tsx
│   │   └── TodoEditorPage.tsx
│   │
│   ├── services/             # API 服务层
│   │   ├── api.ts              # Axios 配置
│   │   ├── auth.service.ts     # 认证 API
│   │   └── todo.service.ts     # TODO API
│   │
│   ├── stores/               # Zustand 状态管理
│   │   ├── authStore.ts
│   │   └── todoStore.ts
│   │
│   ├── types/                # TypeScript 类型
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
│   ├── routes/               # 路由配置
│   │   └── index.tsx
│   │
│   ├── App.tsx               # 应用根组件
│   ├── main.tsx              # 应用入口
│   └── index.css             # 全局样式
│
├── public/                   # 静态资源
├── index.html
├── vite.config.ts
├── tailwind.config.js
├── tsconfig.json
├── postcss.config.js
└── package.json
```

---

## 四、apps/api/ 详细结构（ASP.NET Core）

```
apps/api/
├── SlowPoke.Api/             # Web API 入口项目
│   ├── Endpoints/              # Minimal API 端点
│   │   ├── AuthEndpoints.cs
│   │   ├── TodoEndpoints.cs
│   │   └── HealthEndpoints.cs
│   │
│   ├── Middleware/             # 中间件
│   │   ├── ExceptionHandlingMiddleware.cs
│   │   └── RequestLoggingMiddleware.cs
│   │
│   ├── Extensions/             # 扩展方法
│   │   ├── ServiceCollectionExtensions.cs
│   │   └── ApplicationBuilderExtensions.cs
│   │
│   ├── Program.cs
│   ├── appsettings.json
│   ├── appsettings.Development.json
│   └── SlowPoke.Api.csproj
│
├── SlowPoke.Core/            # 核心业务逻辑
│   ├── Entities/
│   │   └── TodoIndex.cs
│   │
│   ├── Interfaces/
│   │   ├── IRepository.cs
│   │   ├── ITodoRepository.cs
│   │   ├── ITodoFileService.cs
│   │   └── ITodoSyncService.cs
│   │
│   ├── DTOs/
│   │   ├── Requests/
│   │   │   ├── CreateTodoRequest.cs
│   │   │   ├── UpdateTodoRequest.cs
│   │   │   └── LoginRequest.cs
│   │   └── Responses/
│   │       ├── TodoResponse.cs
│   │       ├── TodoListResponse.cs
│   │       └── PagedResponse.cs
│   │
│   ├── Exceptions/
│   │   ├── TodoNotFoundException.cs
│   │   └── InvalidTodoFormatException.cs
│   │
│   └── SlowPoke.Core.csproj
│
├── SlowPoke.Data/            # 数据访问层
│   ├── Repositories/
│   │   ├── BaseRepository.cs
│   │   └── TodoRepository.cs
│   │
│   ├── Context/
│   │   └── SlowPokeDbContext.cs
│   │
│   ├── Configurations/
│   │   └── DatabaseConfiguration.cs
│   │
│   └── SlowPoke.Data.csproj
│
└── SlowPoke.Services/        # 服务层
    ├── TodoFileService.cs
    ├── TodoSyncService.cs
    ├── AuthService.cs
    └── SlowPoke.Services.csproj
```

---

## 五、deployments/ 详细结构

```
deployments/
├── docker/
│   ├── Dockerfile.web          # Web 前端 Dockerfile
│   ├── Dockerfile.api          # API 后端 Dockerfile
│   └── Dockerfile.aio          # All-in-One Dockerfile（单容器）
│
├── docker-compose.yml          # 生产环境
├── docker-compose.dev.yml      # 开发环境
└── .env.example                # 环境变量示例
```

---

## 六、packages/ 详细结构（可选，初期可能不需要）

```
packages/
└── types/                    # 共享类型定义
    ├── todo.ts                 # TODO 相关类型
    ├── api.ts                  # API 接口类型
    └── package.json
```

**说明**：
- 初期可能不需要 `packages/`
- 当前后端需要共享类型定义时再添加
- 可以用 TypeScript + C# 类型生成工具同步类型

---

## 七、与 Plane 的命名对比

| 功能 | Plane 命名 | SlowPoke 命名 | 说明 |
|------|-----------|--------------|------|
| 主 Web 应用 | `apps/web/` | `apps/web/` | ✅ 保持一致 |
| API 服务 | `apps/api/` | `apps/api/` | ✅ 保持一致 |
| 管理界面 | `apps/admin/` | - | ❌ SlowPoke 无需管理界面 |
| 公共空间 | `apps/space/` | - | ❌ SlowPoke 无需公共空间 |
| 共享包 | `packages/` | `packages/` | ✅ 可选，后续添加 |
| 部署配置 | `deployments/` | `deployments/` | ✅ 保持一致 |

---

## 八、项目创建命令

### 1. 创建目录结构

```bash
# 创建主目录
mkdir -p apps/web
mkdir -p apps/api
mkdir -p packages/types
mkdir -p deployments/docker
mkdir -p scripts
mkdir -p docs
```

### 2. 创建 .NET 项目

```bash
# 创建解决方案
dotnet new sln -n SlowPoke

# 在 apps/api 下创建项目
dotnet new web -n SlowPoke.Api -o apps/api/SlowPoke.Api
dotnet new classlib -n SlowPoke.Core -o apps/api/SlowPoke.Core
dotnet new classlib -n SlowPoke.Data -o apps/api/SlowPoke.Data
dotnet new classlib -n SlowPoke.Services -o apps/api/SlowPoke.Services

# 添加到解决方案
dotnet sln add apps/api/SlowPoke.Api
dotnet sln add apps/api/SlowPoke.Core
dotnet sln add apps/api/SlowPoke.Data
dotnet sln add apps/api/SlowPoke.Services

# 设置项目引用
cd apps/api/SlowPoke.Api
dotnet add reference ../SlowPoke.Core
dotnet add reference ../SlowPoke.Data
dotnet add reference ../SlowPoke.Services
cd ../../..

cd apps/api/SlowPoke.Data
dotnet add reference ../SlowPoke.Core
cd ../../..

cd apps/api/SlowPoke.Services
dotnet add reference ../SlowPoke.Core
dotnet add reference ../SlowPoke.Data
cd ../../..
```

### 3. 创建 React 项目

```bash
# 在 apps/web 下创建前端项目
npm create vite@latest apps/web -- --template react-ts

# 安装依赖
cd apps/web
npm install

# 安装核心依赖
npm install react-router@latest zustand@latest axios @uiw/react-md-editor@latest

# 安装 UI 相关
npm install tailwindcss postcss autoprefixer
npm install -D @types/node

# 初始化 Tailwind
npx tailwindcss init -p
```

### 4. 安装 .NET 依赖

```bash
# FreeSql
cd apps/api/SlowPoke.Data
dotnet add package FreeSql
dotnet add package FreeSql.Provider.Sqlite

# Serilog
cd ../SlowPoke.Api
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File

# 其他
dotnet add package Microsoft.AspNetCore.Authentication.Cookies
```

---

## 九、开发脚本（scripts/）

### scripts/dev.sh（开发环境启动）

```bash
#!/bin/bash

# 启动后端
cd apps/api/SlowPoke.Api
dotnet run &

# 启动前端
cd ../../web
npm run dev &

wait
```

### scripts/build.sh（构建脚本）

```bash
#!/bin/bash

# 构建后端
cd apps/api/SlowPoke.Api
dotnet publish -c Release -o ../../../dist/api

# 构建前端
cd ../../web
npm run build
mv dist ../../../dist/web
```

---

## 十、关键优势（参考 Plane）

1. **清晰的应用边界**
   - `apps/web` - 明确是 Web 应用
   - `apps/api` - 明确是 API 服务
   - 不用 "frontend/backend" 这样的技术术语

2. **可扩展性**
   - 未来可以添加 `apps/mobile`（移动端）
   - 可以添加 `apps/admin`（管理界面）
   - 可以添加 `apps/cli`（命令行工具）

3. **共享代码管理**
   - `packages/` 存放共享代码
   - 前后端都可以引用

4. **统一的部署配置**
   - `deployments/` 集中管理
   - 开发和生产环境分离

---

## 十一、下一步

**请确认以上结构，我将：**

1. ✅ 按照 Plane 的命名规范创建项目
2. ✅ 生成所有目录和基础文件
3. ✅ 配置项目引用和依赖
4. ✅ 创建开发脚本

**这个结构是否符合你的预期？**
