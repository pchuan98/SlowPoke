# 部署 User Stories

## US-601: Docker 单容器部署

**作为** 运维人员
**我需要** 使用 Docker 部署应用
**以便** 简化部署流程

### 验收标准

- [ ] 提供 Dockerfile
- [ ] 单个容器包含前后端
- [ ] 基于 ASP.NET Core 官方镜像
- [ ] 支持多阶段构建

### 技术要点

```dockerfile
# Dockerfile
# 阶段 1：构建前端
FROM node:20-alpine AS frontend-build

WORKDIR /app/frontend

# 复制前端源码
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

# 阶段 2：构建后端
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS backend-build

WORKDIR /app/backend

# 复制项目文件
COPY backend/*.csproj ./
RUN dotnet restore

# 复制所有源码
COPY backend/ ./

# 复制前端构建产物到 wwwroot
COPY --from=frontend-build /app/frontend/dist ./wwwroot

# 发布应用
RUN dotnet publish -c Release -o /app/publish

# 阶段 3：运行时镜像
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime

WORKDIR /app

# 复制发布产物
COPY --from=backend-build /app/publish .

# 创建数据目录
RUN mkdir -p /app/data/todos

# 暴露端口
EXPOSE 8080

# 启动应用
ENTRYPOINT ["dotnet", "SlowPoke.dll"]
```

### 构建和运行

```bash
# 构建镜像
docker build -t slowpoke:latest .

# 运行容器
docker run -d \
  --name slowpoke \
  -p 5000:8080 \
  -v slowpoke-data:/app/data \
  -e Auth__Password=your-password \
  slowpoke:latest
```

### .dockerignore

```
# .dockerignore
**/bin/
**/obj/
**/node_modules/
**/dist/
**/.git/
**/.vs/
**/.vscode/
**/data/
**/logs/
```

---

## US-602: 数据目录持久化（data/）

**作为** 用户
**我需要** 持久化数据
**以便** 容器重启后数据不丢失

### 验收标准

- [ ] 使用 Docker Volume 挂载 `/app/data`
- [ ] 包含 SQLite 数据库文件
- [ ] 包含所有 Markdown 文件
- [ ] 支持备份和恢复

### 技术要点

```bash
# 创建 Volume
docker volume create slowpoke-data

# 运行容器并挂载
docker run -d \
  --name slowpoke \
  -p 5000:8080 \
  -v slowpoke-data:/app/data \
  slowpoke:latest

# 查看 Volume 位置
docker volume inspect slowpoke-data

# 备份数据
docker run --rm \
  -v slowpoke-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/slowpoke-backup.tar.gz -C /data .

# 恢复数据
docker run --rm \
  -v slowpoke-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/slowpoke-backup.tar.gz -C /data
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  slowpoke:
    image: slowpoke:latest
    container_name: slowpoke
    ports:
      - "5000:8080"
    environment:
      - Auth__Password=${SLOWPOKE_PASSWORD:-admin}
      - ASPNETCORE_ENVIRONMENT=Production
    volumes:
      - slowpoke-data:/app/data
    restart: unless-stopped

volumes:
  slowpoke-data:
    driver: local
```

```bash
# 使用 Docker Compose 运行
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

### 数据目录结构

```
/app/data/
├── slowpoke.db          # SQLite 数据库
└── todos/               # Markdown 文件
    ├── 3fa85f64-5717-4562-b3fc-2c963f66afa6.md
    ├── 7b8c9d0e-1234-5678-90ab-cdef12345678.md
    └── ...
```

---

## US-603: 首次启动初始化

**作为** 用户
**我需要** 首次启动时的初始化提示
**以便** 了解默认密码

### 验收标准

- [ ] 检测是否首次启动
- [ ] 输出默认密码提示
- [ ] 提示修改密码
- [ ] 创建必要的目录和文件

### 技术要点

```csharp
// Program.cs
var app = builder.Build();

// 首次启动初始化
await InitializeApplication(app.Services);

app.Run();

async Task InitializeApplication(IServiceProvider services)
{
    using var scope = services.CreateScope();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    var config = scope.ServiceProvider.GetRequiredService<IConfiguration>();

    // 检查是否首次启动
    var dbPath = config["Storage:DatabasePath"] ?? "data/slowpoke.db";
    var isFirstRun = !File.Exists(dbPath);

    // 创建必要的目录
    Directory.CreateDirectory("data");
    Directory.CreateDirectory("data/todos");
    Directory.CreateDirectory("logs");

    if (isFirstRun)
    {
        logger.LogWarning("=".PadRight(60, '='));
        logger.LogWarning("首次启动 SlowPoke");
        logger.LogWarning("=".PadRight(60, '='));
        logger.LogWarning("");
        logger.LogWarning("默认登录密码: {Password}",
            config["Auth:DefaultPassword"] ?? "admin");
        logger.LogWarning("");
        logger.LogWarning("强烈建议修改密码！");
        logger.LogWarning("方式 1: 修改 appsettings.json 中的 Auth:Password");
        logger.LogWarning("方式 2: 设置环境变量 Auth__Password");
        logger.LogWarning("");
        logger.LogWarning("=".PadRight(60, '='));
    }

    // 同步文件和数据库
    var syncService = scope.ServiceProvider.GetRequiredService<ITodoSyncService>();
    await syncService.SyncAllTodosAsync();

    logger.LogInformation("Application initialized successfully");
}
```

### 启动日志示例

```
[12:34:56 WRN] ============================================================
[12:34:56 WRN] 首次启动 SlowPoke
[12:34:56 WRN] ============================================================
[12:34:56 WRN]
[12:34:56 WRN] 默认登录密码: admin
[12:34:56 WRN]
[12:34:56 WRN] 强烈建议修改密码！
[12:34:56 WRN] 方式 1: 修改 appsettings.json 中的 Auth:Password
[12:34:56 WRN] 方式 2: 设置环境变量 Auth__Password
[12:34:56 WRN]
[12:34:56 WRN] ============================================================
[12:34:57 INF] Application initialized successfully
```

### 健康检查端点

```csharp
// 添加健康检查
app.MapGet("/health", () =>
{
    return Results.Ok(new
    {
        status = "healthy",
        timestamp = DateTime.UtcNow
    });
});
```

### README 部署指南

```markdown
# SlowPoke 部署指南

## 快速开始

### 使用 Docker

1. 拉取镜像：
   ```bash
   docker pull slowpoke:latest
   ```

2. 运行容器：
   ```bash
   docker run -d \
     --name slowpoke \
     -p 5000:8080 \
     -v slowpoke-data:/app/data \
     -e Auth__Password=your-secure-password \
     slowpoke:latest
   ```

3. 访问应用：
   打开浏览器访问 http://localhost:5000

### 使用 Docker Compose

1. 创建 `docker-compose.yml`：
   ```yaml
   version: '3.8'
   services:
     slowpoke:
       image: slowpoke:latest
       ports:
         - "5000:8080"
       environment:
         - Auth__Password=your-secure-password
       volumes:
         - ./data:/app/data
       restart: unless-stopped
   ```

2. 启动服务：
   ```bash
   docker-compose up -d
   ```

## 配置

### 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `Auth__Password` | 登录密码 | `admin` |
| `Storage__DataDirectory` | 数据目录 | `data` |
| `ASPNETCORE_ENVIRONMENT` | 运行环境 | `Production` |

### 数据持久化

数据存储在 `/app/data` 目录，包含：
- `slowpoke.db`: SQLite 数据库
- `todos/`: Markdown 文件

建议使用 Docker Volume 或本地目录挂载。

### 备份

备份数据目录即可：
```bash
docker run --rm \
  -v slowpoke-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/slowpoke-backup-$(date +%Y%m%d).tar.gz -C /data .
```

### 恢复

```bash
docker run --rm \
  -v slowpoke-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/slowpoke-backup.tar.gz -C /data
```

## 升级

1. 停止旧容器：
   ```bash
   docker stop slowpoke
   docker rm slowpoke
   ```

2. 拉取新镜像：
   ```bash
   docker pull slowpoke:latest
   ```

3. 启动新容器（使用相同的 Volume）：
   ```bash
   docker run -d \
     --name slowpoke \
     -p 5000:8080 \
     -v slowpoke-data:/app/data \
     slowpoke:latest
   ```

## 故障排查

### 查看日志

```bash
# Docker
docker logs -f slowpoke

# Docker Compose
docker-compose logs -f
```

### 进入容器

```bash
docker exec -it slowpoke sh
```

### 检查健康状态

```bash
curl http://localhost:5000/health
```

## 安全建议

1. **修改默认密码**：首次启动后立即修改
2. **使用 HTTPS**：建议配置反向代理（Nginx）
3. **定期备份**：设置自动备份任务
4. **限制访问**：配置防火墙规则

## 性能优化

- 数据库定期 VACUUM
- 日志文件定期清理
- 监控磁盘空间
```
