# TODO CRUD - 后端 User Stories

## 创建 TODO

### US-101: POST /api/todos - 创建 TODO

**作为** 用户
**我想要** 创建一个新的 TODO
**以便** 记录我的任务

### 验收标准

- [ ] POST 请求到 `/api/todos`
- [ ] 请求体包含 `title`（可选）、`fields`（可选）、`content`（可选）
- [ ] 返回 201 状态码和创建的 TODO
- [ ] 同时写入数据库和 Markdown 文件

### 技术要点

```csharp
// Minimal API
app.MapPost("/api/todos", async (
    CreateTodoRequest request,
    IFreeSql freeSql,
    ITodoFileService fileService) =>
{
    var todo = new TodoIndex
    {
        Id = Guid.NewGuid().ToString(),
        Title = request.Title,
        CreatedAt = DateTime.UtcNow.ToString("O"),
        UpdatedAt = DateTime.UtcNow.ToString("O"),
        Fields = JsonSerializer.Serialize(request.Fields ?? new()),
        FilePath = $"data/todos/{id}.md",
        FileModifiedAt = DateTime.UtcNow.ToString("O")
    };

    // 写入数据库
    await freeSql.Insert(todo).ExecuteAffrowsAsync();

    // 写入 Markdown 文件
    await fileService.WriteTodoFile(todo, request.Content);

    return Results.Created($"/api/todos/{todo.Id}", todo);
})
.RequireAuthorization();

public record CreateTodoRequest(
    string? Title,
    Dictionary<string, object>? Fields,
    string? Content
);
```

### API 设计

**请求**:
```json
{
  "title": "实现 TODO 创建功能",
  "fields": {
    "status": "in_progress",
    "priority": "high",
    "project": "SlowPoke"
  },
  "content": "详细描述..."
}
```

**响应**:
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "title": "实现 TODO 创建功能",
  "fields": {
    "status": "in_progress",
    "priority": "high",
    "project": "SlowPoke"
  },
  "content": "详细描述...",
  "createdAt": "2025-11-17T10:00:00Z",
  "updatedAt": "2025-11-17T10:00:00Z"
}
```

---

### US-102: 生成 GUID 作为 id

**作为** 系统
**我需要** 为每个 TODO 生成唯一的 GUID
**以便** 全局唯一标识

### 验收标准

- [ ] 使用 `Guid.NewGuid()` 生成 id
- [ ] GUID 格式：`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- [ ] id 在创建时自动生成，不由客户端提供

### 技术要点

```csharp
var id = Guid.NewGuid().ToString(); // "3fa85f64-5717-4562-b3fc-2c963f66afa6"
```

---

### US-103: 标题可选（为空则使用 id）

**作为** 用户
**我可以** 不提供标题
**系统会** 自动使用 id 作为默认标题

### 验收标准

- [ ] `title` 字段可选
- [ ] 如果 `title` 为空或 null，使用 `id` 作为标题
- [ ] 前端显示时使用标题或 id

### 技术要点

```csharp
var title = string.IsNullOrWhiteSpace(request.Title)
    ? id
    : request.Title;

var todo = new TodoIndex
{
    Id = id,
    Title = title,
    // ...
};
```

---

### US-104: 支持扩展字段（status/priority/project/tags 等）

**作为** 用户
**我想要** 为 TODO 添加自定义字段
**以便** 灵活组织我的任务

### 验收标准

- [ ] `fields` 为 `Dictionary<string, object>` 类型
- [ ] 支持任意自定义字段
- [ ] 常见字段：status、priority、project、tags、dueDate
- [ ] 字段存储为 JSON 字符串

### 技术要点

```csharp
// 存储为 JSON
public class TodoIndex
{
    public string Fields { get; set; } // JSON 字符串
}

// 序列化
var fieldsJson = JsonSerializer.Serialize(request.Fields ?? new());

// 反序列化
var fields = JsonSerializer.Deserialize<Dictionary<string, object>>(todo.Fields);
```

---

### US-105: 支持 Markdown 内容

**作为** 用户
**我想要** 使用 Markdown 编写 TODO 内容
**以便** 记录详细信息

### 验收标准

- [ ] `content` 字段为 Markdown 格式字符串
- [ ] 内容存储在 YAML Front Matter 之后
- [ ] 支持空内容

### 技术要点

```markdown
---
id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
title: 实现 TODO 创建功能
createdAt: 2025-11-17T10:00:00Z
updatedAt: 2025-11-17T10:00:00Z
status: in_progress
priority: high
---

这里是 Markdown 内容...

## 子标题

- 列表项 1
- 列表项 2
```

---

### US-106: 写入数据库索引

**作为** 系统
**我需要** 在创建 TODO 时写入数据库索引
**以便** 快速查询

### 验收标准

- [ ] 使用 FreeSql 插入记录
- [ ] 插入成功返回受影响行数 > 0
- [ ] 异常时回滚事务

### 技术要点

```csharp
// FreeSql 3.5.215 插入
var affectedRows = await freeSql.Insert(todo).ExecuteAffrowsAsync();

if (affectedRows == 0)
{
    throw new InvalidOperationException("Failed to insert todo");
}
```

---

### US-107: 生成 Markdown 文件（data/todos/{id}.md）

**作为** 系统
**我需要** 在创建 TODO 时生成 Markdown 文件
**以便** 用户拥有可读的文件

### 验收标准

- [ ] 文件路径：`data/todos/{id}.md`
- [ ] 包含 YAML Front Matter（所有字段）
- [ ] 包含 Markdown 内容
- [ ] 目录不存在时自动创建

### 技术要点

```csharp
public class TodoFileService : ITodoFileService
{
    private const string TodosDir = "data/todos";

    public async Task WriteTodoFile(TodoIndex todo, string? content)
    {
        // 确保目录存在
        Directory.CreateDirectory(TodosDir);

        var filePath = Path.Combine(TodosDir, $"{todo.Id}.md");

        // 构建 YAML Front Matter
        var yaml = BuildYamlFrontMatter(todo);

        // 写入文件
        var fileContent = $"---\n{yaml}---\n\n{content ?? ""}";
        await File.WriteAllTextAsync(filePath, fileContent);
    }

    private string BuildYamlFrontMatter(TodoIndex todo)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"id: {todo.Id}");

        if (!string.IsNullOrEmpty(todo.Title))
        {
            sb.AppendLine($"title: {todo.Title}");
        }

        sb.AppendLine($"createdAt: {todo.CreatedAt}");
        sb.AppendLine($"updatedAt: {todo.UpdatedAt}");

        // 添加扩展字段
        if (!string.IsNullOrEmpty(todo.Fields))
        {
            var fields = JsonSerializer.Deserialize<Dictionary<string, object>>(todo.Fields);
            foreach (var field in fields)
            {
                sb.AppendLine($"{field.Key}: {FormatYamlValue(field.Value)}");
            }
        }

        return sb.ToString();
    }
}
```

---

## 读取 TODO

### US-111: GET /api/todos - 获取 TODO 列表

**作为** 用户
**我想要** 获取所有 TODO 列表
**以便** 查看我的任务

### 验收标准

- [ ] GET 请求到 `/api/todos`
- [ ] 返回 TODO 数组
- [ ] 不包含 `content` 字段（只返回元数据）
- [ ] 自动过滤 `deleted=true` 的项

### 技术要点

```csharp
app.MapGet("/api/todos", async (
    IFreeSql freeSql,
    int page = 1,
    int pageSize = 20,
    string? sortBy = "createdAt",
    string? sortOrder = "desc") =>
{
    var query = freeSql.Select<TodoIndex>()
        .Where(t => t.Deleted == 0);

    // 排序
    query = sortBy?.ToLower() switch
    {
        "updatedat" => sortOrder == "asc"
            ? query.OrderBy(t => t.UpdatedAt)
            : query.OrderByDescending(t => t.UpdatedAt),
        _ => sortOrder == "asc"
            ? query.OrderBy(t => t.CreatedAt)
            : query.OrderByDescending(t => t.CreatedAt)
    };

    // 分页
    var total = await query.CountAsync();
    var items = await query
        .Page(page, pageSize)
        .ToListAsync();

    return Results.Ok(new
    {
        total,
        page,
        pageSize,
        items = items.Select(t => new
        {
            t.Id,
            t.Title,
            Fields = JsonSerializer.Deserialize<Dictionary<string, object>>(t.Fields ?? "{}"),
            t.CreatedAt,
            t.UpdatedAt
        })
    });
})
.RequireAuthorization();
```

### API 设计

**请求**: `GET /api/todos?page=1&pageSize=20&sortBy=createdAt&sortOrder=desc`

**响应**:
```json
{
  "total": 100,
  "page": 1,
  "pageSize": 20,
  "items": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "title": "实现 TODO 创建功能",
      "fields": {
        "status": "in_progress",
        "priority": "high"
      },
      "createdAt": "2025-11-17T10:00:00Z",
      "updatedAt": "2025-11-17T12:00:00Z"
    }
  ]
}
```

---

### US-112: 列表返回 id/title/fields/createdAt/updatedAt（不含 content）

**作为** 系统
**我需要** 在列表接口中排除 content
**以便** 减少数据传输量

### 验收标准

- [ ] 列表接口不返回 `content` 字段
- [ ] 返回：id、title、fields、createdAt、updatedAt
- [ ] fields 反序列化为对象

### 技术要点

```csharp
items = items.Select(t => new
{
    t.Id,
    t.Title,
    Fields = JsonSerializer.Deserialize<Dictionary<string, object>>(t.Fields ?? "{}"),
    t.CreatedAt,
    t.UpdatedAt
})
```

---

### US-113: 列表支持分页

**作为** 用户
**我想要** 分页加载 TODO
**以便** 处理大量数据

### 验收标准

- [ ] 支持 `page` 参数（默认 1）
- [ ] 支持 `pageSize` 参数（默认 20）
- [ ] 返回 `total` 总数

### 技术要点

```csharp
// FreeSql 分页
var total = await query.CountAsync();
var items = await query
    .Page(page, pageSize) // Page(页码, 每页数量)
    .ToListAsync();
```

---

### US-114: 列表支持排序（createdAt/updatedAt）

**作为** 用户
**我想要** 按不同字段排序
**以便** 查看最新或最早的任务

### 验收标准

- [ ] 支持 `sortBy` 参数：createdAt、updatedAt
- [ ] 支持 `sortOrder` 参数：asc、desc
- [ ] 默认：createdAt desc

### 技术要点

```csharp
query = sortBy?.ToLower() switch
{
    "updatedat" => sortOrder == "asc"
        ? query.OrderBy(t => t.UpdatedAt)
        : query.OrderByDescending(t => t.UpdatedAt),
    _ => sortOrder == "asc"
        ? query.OrderBy(t => t.CreatedAt)
        : query.OrderByDescending(t => t.CreatedAt)
};
```

---

### US-115: 列表自动过滤 deleted=true

**作为** 用户
**我不想** 在列表中看到已删除的 TODO
**系统会** 自动过滤

### 验收标准

- [ ] 查询时添加 `WHERE Deleted = 0`
- [ ] 已删除的 TODO 不出现在列表中

### 技术要点

```csharp
var query = freeSql.Select<TodoIndex>()
    .Where(t => t.Deleted == 0);
```

---

### US-116: GET /api/todos/{id} - 获取 TODO 详情

**作为** 用户
**我想要** 查看 TODO 的完整详情
**以便** 阅读完整内容

### 验收标准

- [ ] GET 请求到 `/api/todos/{id}`
- [ ] 返回完整的 TODO（包含 content）
- [ ] id 不存在时返回 404

### 技术要点

```csharp
app.MapGet("/api/todos/{id}", async (
    string id,
    IFreeSql freeSql,
    ITodoFileService fileService) =>
{
    var todo = await freeSql.Select<TodoIndex>()
        .Where(t => t.Id == id && t.Deleted == 0)
        .FirstAsync();

    if (todo == null)
    {
        return Results.NotFound(new { error = "Todo not found" });
    }

    // 读取 Markdown 文件内容
    var content = await fileService.ReadTodoContent(todo.Id);

    return Results.Ok(new
    {
        todo.Id,
        todo.Title,
        Fields = JsonSerializer.Deserialize<Dictionary<string, object>>(todo.Fields ?? "{}"),
        Content = content,
        todo.CreatedAt,
        todo.UpdatedAt
    });
})
.RequireAuthorization();
```

---

### US-117: 详情返回完整 content

**作为** 用户
**我需要** 在详情接口中获取完整 Markdown 内容
**以便** 查看和编辑

### 验收标准

- [ ] 从 Markdown 文件读取 content
- [ ] content 在 YAML Front Matter 之后
- [ ] 返回原始 Markdown 字符串

### 技术要点

```csharp
public async Task<string> ReadTodoContent(string id)
{
    var filePath = Path.Combine(TodosDir, $"{id}.md");

    if (!File.Exists(filePath))
    {
        return string.Empty;
    }

    var fileContent = await File.ReadAllTextAsync(filePath);

    // 解析 YAML Front Matter
    var yamlEndIndex = fileContent.IndexOf("---", 3);
    if (yamlEndIndex == -1)
    {
        return fileContent;
    }

    // 返回 YAML 之后的内容
    return fileContent.Substring(yamlEndIndex + 3).Trim();
}
```

---

## 更新 TODO

### US-121: PATCH /api/todos/{id} - 更新 TODO

**作为** 用户
**我想要** 更新 TODO 的信息
**以便** 修改任务详情

### 验收标准

- [ ] PATCH 请求到 `/api/todos/{id}`
- [ ] 支持部分更新（只传需要更新的字段）
- [ ] 返回更新后的 TODO
- [ ] id 不存在时返回 404

### 技术要点

```csharp
app.MapPatch("/api/todos/{id}", async (
    string id,
    UpdateTodoRequest request,
    IFreeSql freeSql,
    ITodoFileService fileService) =>
{
    var todo = await freeSql.Select<TodoIndex>()
        .Where(t => t.Id == id && t.Deleted == 0)
        .FirstAsync();

    if (todo == null)
    {
        return Results.NotFound(new { error = "Todo not found" });
    }

    // 更新字段
    if (request.Title != null)
    {
        todo.Title = request.Title;
    }

    if (request.Fields != null)
    {
        todo.Fields = JsonSerializer.Serialize(request.Fields);
    }

    todo.UpdatedAt = DateTime.UtcNow.ToString("O");

    // 更新数据库
    await freeSql.Update<TodoIndex>()
        .SetSource(todo)
        .ExecuteAffrowsAsync();

    // 更新 Markdown 文件
    await fileService.WriteTodoFile(todo, request.Content);

    return Results.Ok(todo);
})
.RequireAuthorization();

public record UpdateTodoRequest(
    string? Title,
    Dictionary<string, object>? Fields,
    string? Content
);
```

---

### US-122: 支持更新 title

**作为** 用户
**我想要** 修改 TODO 标题
**以便** 更准确描述任务

### 验收标准

- [ ] 支持传入新的 `title`
- [ ] title 为 null 时不更新
- [ ] 同步更新数据库和 Markdown 文件

---

### US-123: 支持更新扩展字段

**作为** 用户
**我想要** 修改 TODO 的自定义字段
**以便** 更新任务状态和属性

### 验收标准

- [ ] 支持传入新的 `fields`
- [ ] 支持部分更新字段
- [ ] 同步更新数据库和 Markdown 文件

### 技术要点

```csharp
// 部分更新字段
if (request.Fields != null)
{
    var currentFields = JsonSerializer.Deserialize<Dictionary<string, object>>(todo.Fields ?? "{}");

    // 合并字段
    foreach (var field in request.Fields)
    {
        currentFields[field.Key] = field.Value;
    }

    todo.Fields = JsonSerializer.Serialize(currentFields);
}
```

---

### US-124: 支持更新 content

**作为** 用户
**我想要** 修改 TODO 的 Markdown 内容
**以便** 更新任务详情

### 验收标准

- [ ] 支持传入新的 `content`
- [ ] content 为 null 时不更新
- [ ] 同步更新 Markdown 文件

---

### US-125: 自动更新 updatedAt

**作为** 系统
**我需要** 在每次更新时自动更新时间戳
**以便** 追踪修改历史

### 验收标准

- [ ] 每次 PATCH 请求自动更新 `updatedAt`
- [ ] 使用 UTC 时间
- [ ] 格式：ISO 8601（`2025-11-17T10:00:00Z`）

### 技术要点

```csharp
todo.UpdatedAt = DateTime.UtcNow.ToString("O"); // ISO 8601 格式
```

---

### US-126: 同步更新数据库索引

**作为** 系统
**我需要** 在更新 TODO 时同步数据库
**以便** 保持索引准确

### 验收标准

- [ ] 使用 FreeSql 更新记录
- [ ] 更新成功返回受影响行数 > 0

### 技术要点

```csharp
var affectedRows = await freeSql.Update<TodoIndex>()
    .SetSource(todo)
    .ExecuteAffrowsAsync();

if (affectedRows == 0)
{
    return Results.Problem("Failed to update todo");
}
```

---

### US-127: 同步更新 Markdown 文件

**作为** 系统
**我需要** 在更新 TODO 时同步 Markdown 文件
**以便** 用户看到最新内容

### 验收标准

- [ ] 调用 `WriteTodoFile` 重新生成文件
- [ ] 保留完整的 YAML Front Matter
- [ ] 更新 content 部分

---

## 删除 TODO

### US-131: DELETE /api/todos/{id} - 软删除 TODO

**作为** 用户
**我想要** 删除不需要的 TODO
**但系统会** 保留记录以便恢复

### 验收标准

- [ ] DELETE 请求到 `/api/todos/{id}`
- [ ] 使用软删除（不物理删除）
- [ ] 返回 200 状态码
- [ ] id 不存在时返回 404

### 技术要点

```csharp
app.MapDelete("/api/todos/{id}", async (
    string id,
    IFreeSql freeSql,
    ITodoFileService fileService) =>
{
    var todo = await freeSql.Select<TodoIndex>()
        .Where(t => t.Id == id)
        .FirstAsync();

    if (todo == null)
    {
        return Results.NotFound(new { error = "Todo not found" });
    }

    // 软删除
    todo.Deleted = 1;
    todo.DeletedAt = DateTime.UtcNow.ToString("O");
    todo.UpdatedAt = DateTime.UtcNow.ToString("O");

    // 更新数据库
    await freeSql.Update<TodoIndex>()
        .SetSource(todo)
        .ExecuteAffrowsAsync();

    // 更新 Markdown 文件（添加 deleted 字段）
    await fileService.MarkTodoAsDeleted(todo);

    return Results.Ok(new { success = true, id });
})
.RequireAuthorization();
```

---

### US-132: 在 YAML 添加 deleted=true

**作为** 系统
**我需要** 在删除时标记 Markdown 文件
**以便** 文件也反映删除状态

### 验收标准

- [ ] 在 YAML Front Matter 添加 `deleted: true`
- [ ] 保留原有所有字段
- [ ] 不删除文件内容

### 技术要点

```markdown
---
id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
title: 实现 TODO 创建功能
createdAt: 2025-11-17T10:00:00Z
updatedAt: 2025-11-17T15:30:00Z
deleted: true
deletedAt: 2025-11-17T16:00:00Z
status: in_progress
---

原有内容保留...
```

---

### US-133: 在 YAML 添加 deletedAt

**作为** 系统
**我需要** 记录删除时间
**以便** 追踪删除历史

### 验收标准

- [ ] 在 YAML Front Matter 添加 `deletedAt`
- [ ] 使用 UTC 时间，ISO 8601 格式

---

### US-134: 更新数据库 Deleted 和 DeletedAt 字段

**作为** 系统
**我需要** 在数据库中标记删除
**以便** 查询时过滤

### 验收标准

- [ ] 设置 `Deleted = 1`
- [ ] 设置 `DeletedAt` 时间戳
- [ ] 更新 `UpdatedAt`

---

### US-135: 删除操作幂等

**作为** 系统
**我需要** 确保删除操作幂等
**以便** 重复删除不报错

### 验收标准

- [ ] 多次删除同一 TODO 均返回成功
- [ ] 已删除的 TODO 再次删除时返回 200
- [ ] 不抛出异常

### 技术要点

```csharp
// 即使已经 deleted=1，也返回成功
if (todo.Deleted == 1)
{
    return Results.Ok(new { success = true, id, message = "Already deleted" });
}

// 继续执行软删除...
```
