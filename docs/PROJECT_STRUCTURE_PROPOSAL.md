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
│   │   │   │   │   ├── select.tsx
│   │   │   │   │   ├── toast.tsx
│   │   │   │   │   └── ...
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
│   │   ├── .eslintrc.cjs
│   │   ├── .prettierrc
│   │   └── package.json
│   │
│   └── api/                                # ASP.NET Core API
│       ├── SlowPoke.Api/                     # Web API 入口项目
│       │   ├── Endpoints/
│       │   │   ├── AuthEndpoints.cs
│       │   │   ├── TodoEndpoints.cs
│       │   │   └── HealthEndpoints.cs
│       │   │
│       │   ├── Middleware/
│       │   │   ├── ExceptionHandlingMiddleware.cs
│       │   │   └── RequestLoggingMiddleware.cs
│       │   │
│       │   ├── Extensions/
│       │   │   ├── ServiceCollectionExtensions.cs
│       │   │   └── ApplicationBuilderExtensions.cs
│       │   │
│       │   ├── Properties/
│       │   │   └── launchSettings.json
│       │   │
│       │   ├── Program.cs
│       │   ├── appsettings.json
│       │   ├── appsettings.Development.json
│       │   └── SlowPoke.Api.csproj
│       │
│       ├── SlowPoke.Core/                    # 核心业务逻辑
│       │   ├── Entities/
│       │   │   └── TodoIndex.cs
│       │   │
│       │   ├── Interfaces/
│       │   │   ├── IRepository.cs
│       │   │   ├── ITodoRepository.cs
│       │   │   ├── ITodoFileService.cs
│       │   │   └── ITodoSyncService.cs
│       │   │
│       │   ├── DTOs/
│       │   │   ├── Requests/
│       │   │   │   ├── CreateTodoRequest.cs
│       │   │   │   ├── UpdateTodoRequest.cs
│       │   │   │   └── LoginRequest.cs
│       │   │   │
│       │   │   └── Responses/
│       │   │       ├── TodoResponse.cs
│       │   │       ├── TodoListResponse.cs
│       │   │       └── PagedResponse.cs
│       │   │
│       │   ├── Exceptions/
│       │   │   ├── TodoNotFoundException.cs
│       │   │   └── InvalidTodoFormatException.cs
│       │   │
│       │   └── SlowPoke.Core.csproj
│       │
│       ├── SlowPoke.Data/                    # 数据访问层
│       │   ├── Repositories/
│       │   │   ├── BaseRepository.cs
│       │   │   └── TodoRepository.cs
│       │   │
│       │   ├── Context/
│       │   │   └── SlowPokeDbContext.cs
│       │   │
│       │   ├── Configurations/
│       │   │   └── DatabaseConfiguration.cs
│       │   │
│       │   └── SlowPoke.Data.csproj
│       │
│       └── SlowPoke.Services/                # 服务层
│           ├── TodoFileService.cs
│           ├── TodoSyncService.cs
│           ├── AuthService.cs
│           └── SlowPoke.Services.csproj
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

### 2.1 components/ 组织

```
components/
├── ui/                     # shadcn/ui 基础组件（从官方复制）
│   ├── button.tsx           # 按钮组件
│   ├── input.tsx            # 输入框组件
│   ├── card.tsx             # 卡片组件
│   ├── badge.tsx            # 徽章组件
│   ├── dialog.tsx           # 对话框组件
│   ├── alert-dialog.tsx     # 警告对话框
│   ├── select.tsx           # 下拉选择
│   ├── toast.tsx            # 提示消息
│   ├── label.tsx            # 标签
│   └── ...                  # 其他 UI 组件
│
├── common/                 # 项目通用组件
│   ├── Header.tsx           # 页面头部
│   ├── Loading.tsx          # 加载指示器
│   ├── ErrorBoundary.tsx    # 错误边界
│   └── EmptyState.tsx       # 空状态提示
│
├── todo/                   # TODO 功能组件
│   ├── TodoCard.tsx         # TODO 卡片（单个）
│   ├── TodoList.tsx         # TODO 列表
│   ├── TodoFieldsForm.tsx   # TODO 字段表单
│   ├── DeleteTodoDialog.tsx # 删除确认对话框
│   └── SortSelector.tsx     # 排序选择器
│
├── editor/                 # 编辑器相关
│   └── MarkdownEditor.tsx   # Markdown 编辑器封装
│
└── layouts/                # 布局组件
    ├── ProtectedLayout.tsx  # 需要认证的布局
    └── PublicLayout.tsx     # 公开布局（登录页）
```

### 2.2 pages/ 组织

```
pages/
├── LoginPage.tsx           # 登录页面（/login）
├── HomePage.tsx            # 主页（/）- TODO 列表
└── TodoEditorPage.tsx      # TODO 编辑页（/todos/new 和 /todos/:id）
```

### 2.3 services/ 组织

```
services/
├── api.ts                  # Axios 实例配置
│                             - baseURL
│                             - 拦截器（401 处理）
│                             - 请求/响应转换
│
├── auth.service.ts         # 认证相关 API
│                             - login()
│                             - logout()
│
└── todo.service.ts         # TODO 相关 API
                              - getTodos()
                              - getTodoById()
                              - createTodo()
                              - updateTodo()
                              - deleteTodo()
```

### 2.4 stores/ 组织（Zustand）

```
stores/
├── authStore.ts            # 认证状态
│                             - isAuthenticated
│                             - login()
│                             - logout()
│
└── todoStore.ts            # TODO 状态
                              - todos: Todo[]
                              - total: number
                              - loading: boolean
                              - fetchTodos()
                              - createTodo()
                              - updateTodo()
                              - deleteTodo()
```

### 2.5 types/ 组织

```
types/
├── todo.ts                 # TODO 类型定义
│                             - Todo
│                             - TodoField
│                             - CreateTodoRequest
│                             - UpdateTodoRequest
│
├── auth.ts                 # 认证类型
│                             - LoginRequest
│                             - LoginResponse
│
└── api.ts                  # API 通用类型
                              - ApiResponse<T>
                              - PagedResponse<T>
```

---

## 三、apps/api 详细说明

### 3.1 SlowPoke.Api 项目结构

```
SlowPoke.Api/
├── Endpoints/              # Minimal API 端点定义
│   ├── AuthEndpoints.cs     # /api/auth/login, /api/auth/logout
│   ├── TodoEndpoints.cs     # /api/todos CRUD
│   └── HealthEndpoints.cs   # /api/system/health
│
├── Middleware/             # 中间件
│   ├── ExceptionHandlingMiddleware.cs  # 全局异常处理
│   └── RequestLoggingMiddleware.cs     # 请求日志
│
├── Extensions/             # 扩展方法
│   ├── ServiceCollectionExtensions.cs  # 服务注册
│   └── ApplicationBuilderExtensions.cs # 中间件配置
│
├── Properties/
│   └── launchSettings.json  # 启动配置
│
├── Program.cs              # 应用入口
├── appsettings.json        # 配置文件
└── SlowPoke.Api.csproj
```

### 3.2 SlowPoke.Core 项目结构

```
SlowPoke.Core/
├── Entities/               # 实体模型
│   └── TodoIndex.cs         # TODO 数据库实体
│
├── Interfaces/             # 接口定义
│   ├── IRepository.cs       # 通用仓储接口
│   ├── ITodoRepository.cs   # TODO 仓储接口
│   ├── ITodoFileService.cs  # 文件服务接口
│   └── ITodoSyncService.cs  # 同步服务接口
│
├── DTOs/                   # 数据传输对象
│   ├── Requests/
│   │   ├── CreateTodoRequest.cs
│   │   ├── UpdateTodoRequest.cs
│   │   └── LoginRequest.cs
│   │
│   └── Responses/
│       ├── TodoResponse.cs
│       ├── TodoListResponse.cs
│       └── PagedResponse.cs
│
├── Exceptions/             # 自定义异常
│   ├── TodoNotFoundException.cs
│   └── InvalidTodoFormatException.cs
│
└── SlowPoke.Core.csproj
```

### 3.3 SlowPoke.Data 项目结构

```
SlowPoke.Data/
├── Repositories/           # 仓储实现
│   ├── BaseRepository.cs    # 基础仓储（通用 CRUD）
│   └── TodoRepository.cs    # TODO 仓储（特定查询）
│
├── Context/                # 数据库上下文
│   └── SlowPokeDbContext.cs # FreeSql 配置
│
├── Configurations/         # 数据库配置
│   └── DatabaseConfiguration.cs
│
└── SlowPoke.Data.csproj
```

### 3.4 SlowPoke.Services 项目结构

```
SlowPoke.Services/
├── TodoFileService.cs      # Markdown 文件操作
│                             - WriteTodoFile()
│                             - ReadTodoContent()
│                             - ParseTodoFile()
│                             - MarkTodoAsDeleted()
│
├── TodoSyncService.cs      # 文件与数据库同步
│                             - SyncAllTodosAsync()
│                             - SyncSingleTodoAsync()
│
├── AuthService.cs          # 认证服务
│                             - ValidatePassword()
│
└── SlowPoke.Services.csproj
```

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

### 4.2 apps/web/tailwind.config.js

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

### 4.3 apps/web/tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### 4.4 apps/api/SlowPoke.Api/appsettings.json

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

---

## 五、项目创建步骤

### 步骤 1: 创建目录结构

```bash
# 创建主目录
mkdir -p apps/web/src/{components/{ui,common,todo,editor,layouts},pages,services,stores,types,hooks,utils,routes}
mkdir -p apps/web/public
mkdir -p apps/api
mkdir -p packages/types
mkdir -p deployments/docker
mkdir -p scripts
```

### 步骤 2: 创建 .NET 项目

```bash
# 创建解决方案
dotnet new sln -n SlowPoke

# 创建后端项目
dotnet new web -n SlowPoke.Api -o apps/api/SlowPoke.Api
dotnet new classlib -n SlowPoke.Core -o apps/api/SlowPoke.Core
dotnet new classlib -n SlowPoke.Data -o apps/api/SlowPoke.Data
dotnet new classlib -n SlowPoke.Services -o apps/api/SlowPoke.Services

# 添加到解决方案
dotnet sln add apps/api/SlowPoke.Api
dotnet sln add apps/api/SlowPoke.Core
dotnet sln add apps/api/SlowPoke.Data
dotnet sln add apps/api/SlowPoke.Services

# 配置项目引用
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

### 步骤 3: 创建 React 项目

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

# 安装开发工具
npm install -D @types/node eslint prettier

cd ../..
```

### 步骤 4: 安装后端依赖

```bash
# FreeSql
cd apps/api/SlowPoke.Data
dotnet add package FreeSql
dotnet add package FreeSql.Provider.Sqlite
cd ../../..

# Serilog
cd apps/api/SlowPoke.Api
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
dotnet add package Microsoft.AspNetCore.Authentication.Cookies
cd ../../..
```

---

## 六、下一步

**这个完全展开的结构清晰吗？**

如果确认，我将立即：
1. ✅ 创建所有目录
2. ✅ 生成项目文件
3. ✅ 创建基础代码模板
4. ✅ 配置所有依赖
