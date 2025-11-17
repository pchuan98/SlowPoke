# 数据存储架构 User Stories

## 数据库索引

### US-401: 创建 TodoIndex 表结构

**作为** 开发者
**我需要** 创建数据库表
**以便** 存储 TODO 索引

### 验收标准

- [ ] 使用 FreeSql 3.5.215 创建表
- [ ] 表名：`TodoIndex`
- [ ] 包含所有必需字段
- [ ] 使用 SQLite 数据库

### 技术要点

```csharp
// Models/TodoIndex.cs
using FreeSql.DataAnnotations;

[Table(Name = "TodoIndex")]
public class TodoIndex
{
    /// <summary>
    /// GUID 格式的唯一标识
    /// </summary>
    [Column(IsPrimary = true, StringLength = 36)]
    public string Id { get; set; } = string.Empty;

    /// <summary>
    /// 标题，可为 null（默认使用 id）
    /// </summary>
    [Column(StringLength = 500)]
    public string? Title { get; set; }

    /// <summary>
    /// 创建时间，ISO 8601 格式
    /// </summary>
    [Column(StringLength = 50)]
    public string CreatedAt { get; set; } = string.Empty;

    /// <summary>
    /// 最后修改时间，ISO 8601 格式
    /// </summary>
    [Column(StringLength = 50)]
    public string UpdatedAt { get; set; } = string.Empty;

    /// <summary>
    /// 软删除标记，0=未删除，1=已删除
    /// </summary>
    [Column]
    public int Deleted { get; set; } = 0;

    /// <summary>
    /// 删除时间，ISO 8601 格式
    /// </summary>
    [Column(StringLength = 50)]
    public string? DeletedAt { get; set; }

    /// <summary>
    /// 扩展字段，JSON 格式
    /// </summary>
    [Column(StringLength = -1)] // TEXT 类型
    public string? Fields { get; set; }

    /// <summary>
    /// Markdown 文件路径
    /// </summary>
    [Column(StringLength = 500)]
    public string FilePath { get; set; } = string.Empty;

    /// <summary>
    /// 文件修改时间，用于同步检测
    /// </summary>
    [Column(StringLength = 50)]
    public string FileModifiedAt { get; set; } = string.Empty;
}
```

### FreeSql 配置

```csharp
// Program.cs
using FreeSql;

var builder = WebApplication.CreateBuilder(args);

// 配置 FreeSql
var freeSql = new FreeSqlBuilder()
    .UseConnectionString(DataType.Sqlite, "Data Source=data/slowpoke.db")
    .UseAutoSyncStructure(true) // 自动同步表结构
    .Build();

builder.Services.AddSingleton<IFreeSql>(freeSql);

// 确保数据库文件目录存在
Directory.CreateDirectory("data");

var app = builder.Build();
```

---

### US-402: 创建数据库索引（CreatedAt/UpdatedAt/Deleted）

**作为** 开发者
**我需要** 创建数据库索引
**以便** 优化查询性能

### 验收标准

- [ ] CreatedAt 字段索引
- [ ] UpdatedAt 字段索引
- [ ] Deleted 字段索引
- [ ] 使用 FreeSql CodeFirst 自动创建

### 技术要点

```csharp
// Models/TodoIndex.cs
using FreeSql.DataAnnotations;

[Table(Name = "TodoIndex")]
[Index("idx_created", nameof(CreatedAt))]
[Index("idx_updated", nameof(UpdatedAt))]
[Index("idx_deleted", nameof(Deleted))]
public class TodoIndex
{
    // ... 字段定义
}
```

或使用 SQL 创建索引：

```sql
CREATE INDEX idx_created ON TodoIndex(CreatedAt);
CREATE INDEX idx_updated ON TodoIndex(UpdatedAt);
CREATE INDEX idx_deleted ON TodoIndex(Deleted);
```

---

## Markdown 文件

### US-411: 创建 data/todos/ 目录结构

**作为** 系统
**我需要** 创建文件存储目录
**以便** 保存 Markdown 文件

### 验收标准

- [ ] 应用启动时检查目录存在
- [ ] 目录不存在时自动创建
- [ ] 目录路径：`data/todos/`

### 技术要点

```csharp
// Program.cs
var app = builder.Build();

// 确保目录存在
Directory.CreateDirectory("data/todos");

app.Run();
```

或使用服务初始化：

```csharp
// Services/TodoFileService.cs
public class TodoFileService : ITodoFileService
{
    private const string TodosDirectory = "data/todos";

    public TodoFileService()
    {
        // 构造函数中确保目录存在
        Directory.CreateDirectory(TodosDirectory);
    }
}
```

---

### US-412: 定义 Markdown 文件命名规则（{id}.md）

**作为** 开发者
**我需要** 定义文件命名规则
**以便** 统一管理文件

### 验收标准

- [ ] 文件名 = `{id}.md`
- [ ] id 为 GUID 格式（带连字符）
- [ ] 扩展名固定为 `.md`

### 技术要点

```csharp
public class TodoFileService : ITodoFileService
{
    private const string TodosDirectory = "data/todos";

    public string GetFilePath(string id)
    {
        // 验证 id 格式
        if (!Guid.TryParse(id, out _))
        {
            throw new ArgumentException("Invalid GUID format", nameof(id));
        }

        return Path.Combine(TodosDirectory, $"{id}.md");
    }
}
```

### 文件路径示例

```
data/todos/3fa85f64-5717-4562-b3fc-2c963f66afa6.md
data/todos/7b8c9d0e-1234-5678-90ab-cdef12345678.md
```

---

### US-413: 定义 YAML Front Matter 格式规范

**作为** 开发者
**我需要** 定义 YAML 格式
**以便** 统一文件结构

### 验收标准

- [ ] 使用 `---` 作为分隔符
- [ ] 包含核心字段：id、title、createdAt、updatedAt
- [ ] 包含系统字段：deleted、deletedAt（删除时）
- [ ] 包含扩展字段：status、priority 等

### 技术要点

**未删除的 TODO**:
```markdown
---
id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
title: 实现 TODO 创建功能
createdAt: 2025-11-17T10:00:00Z
updatedAt: 2025-11-17T15:30:00Z
status: in_progress
priority: high
project: SlowPoke
tags:
  - backend
  - api
---

## 任务描述

详细内容...
```

**已删除的 TODO**:
```markdown
---
id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
title: 实现 TODO 创建功能
createdAt: 2025-11-17T10:00:00Z
updatedAt: 2025-11-17T15:30:00Z
deleted: true
deletedAt: 2025-11-17T16:00:00Z
status: done
---

内容保留...
```

### YAML 生成代码

```csharp
public string BuildYamlFrontMatter(TodoIndex todo, Dictionary<string, object>? fields = null)
{
    var sb = new StringBuilder();

    // 核心字段
    sb.AppendLine($"id: {todo.Id}");

    if (!string.IsNullOrEmpty(todo.Title))
    {
        sb.AppendLine($"title: {EscapeYamlString(todo.Title)}");
    }

    sb.AppendLine($"createdAt: {todo.CreatedAt}");
    sb.AppendLine($"updatedAt: {todo.UpdatedAt}");

    // 系统字段（删除）
    if (todo.Deleted == 1)
    {
        sb.AppendLine("deleted: true");
        if (!string.IsNullOrEmpty(todo.DeletedAt))
        {
            sb.AppendLine($"deletedAt: {todo.DeletedAt}");
        }
    }

    // 扩展字段
    if (fields != null)
    {
        foreach (var field in fields)
        {
            sb.AppendLine($"{field.Key}: {FormatYamlValue(field.Value)}");
        }
    }

    return sb.ToString();
}

private string FormatYamlValue(object value)
{
    return value switch
    {
        string s => EscapeYamlString(s),
        bool b => b.ToString().ToLower(),
        null => "null",
        _ => value.ToString() ?? "null"
    };
}

private string EscapeYamlString(string value)
{
    // 包含特殊字符时用引号包裹
    if (value.Contains(':') || value.Contains('#') || value.Contains('\n'))
    {
        return $"\"{value.Replace("\"", "\\\"")}\"";
    }
    return value;
}
```

---

## 文件同步机制

### US-421: 启动时扫描 data/todos/，重建索引

**作为** 系统
**我需要** 在启动时同步文件和数据库
**以便** 恢复数据一致性

### 验收标准

- [ ] 应用启动时扫描 `data/todos/` 目录
- [ ] 读取所有 `.md` 文件
- [ ] 解析 YAML Front Matter
- [ ] 更新或插入数据库索引

### 技术要点

```csharp
// Services/TodoSyncService.cs
public interface ITodoSyncService
{
    Task SyncAllTodosAsync();
}

public class TodoSyncService : ITodoSyncService
{
    private const string TodosDirectory = "data/todos";
    private readonly IFreeSql _freeSql;
    private readonly ITodoFileService _fileService;

    public TodoSyncService(IFreeSql freeSql, ITodoFileService fileService)
    {
        _freeSql = freeSql;
        _fileService = fileService;
    }

    public async Task SyncAllTodosAsync()
    {
        if (!Directory.Exists(TodosDirectory))
        {
            return;
        }

        var files = Directory.GetFiles(TodosDirectory, "*.md");

        foreach (var filePath in files)
        {
            try
            {
                var fileName = Path.GetFileNameWithoutExtension(filePath);

                // 验证文件名是否为 GUID
                if (!Guid.TryParse(fileName, out _))
                {
                    continue;
                }

                // 解析文件
                var todoData = await _fileService.ParseTodoFile(filePath);

                // 检查数据库中是否存在
                var existing = await _freeSql.Select<TodoIndex>()
                    .Where(t => t.Id == todoData.Id)
                    .FirstAsync();

                if (existing == null)
                {
                    // 插入新记录
                    await _freeSql.Insert(todoData).ExecuteAffrowsAsync();
                }
                else
                {
                    // 更新现有记录
                    await _freeSql.Update<TodoIndex>()
                        .SetSource(todoData)
                        .ExecuteAffrowsAsync();
                }
            }
            catch (Exception ex)
            {
                // 记录错误但继续处理其他文件
                Console.WriteLine($"Failed to sync file {filePath}: {ex.Message}");
            }
        }
    }
}
```

### 应用启动时调用

```csharp
// Program.cs
var app = builder.Build();

// 启动时同步文件
using (var scope = app.Services.CreateScope())
{
    var syncService = scope.ServiceProvider.GetRequiredService<ITodoSyncService>();
    await syncService.SyncAllTodosAsync();
}

app.Run();
```

---

### US-422: 检测外部文件修改（FileModifiedAt 对比）

**作为** 系统
**我需要** 检测文件是否被外部修改
**以便** 同步最新内容

### 验收标准

- [ ] 对比数据库中的 `FileModifiedAt` 和文件实际修改时间
- [ ] 时间不一致时重新解析文件
- [ ] 更新数据库索引

### 技术要点

```csharp
public async Task<bool> CheckFileModified(string id)
{
    var todo = await _freeSql.Select<TodoIndex>()
        .Where(t => t.Id == id)
        .FirstAsync();

    if (todo == null)
    {
        return false;
    }

    var filePath = GetFilePath(id);
    if (!File.Exists(filePath))
    {
        return false;
    }

    var fileInfo = new FileInfo(filePath);
    var fileModifiedAt = fileInfo.LastWriteTimeUtc.ToString("O");

    return fileModifiedAt != todo.FileModifiedAt;
}
```

---

### US-423: 外部修改时重新解析文件并更新索引

**作为** 系统
**我需要** 重新解析被修改的文件
**以便** 保持数据库同步

### 验收标准

- [ ] 读取 Markdown 文件
- [ ] 解析 YAML Front Matter
- [ ] 提取 content
- [ ] 更新数据库索引

### 技术要点

```csharp
public async Task<TodoIndex> ParseTodoFile(string filePath)
{
    var content = await File.ReadAllTextAsync(filePath);

    // 检查 YAML Front Matter
    if (!content.StartsWith("---"))
    {
        throw new InvalidOperationException("Invalid markdown file format");
    }

    // 查找第二个 ---
    var yamlEndIndex = content.IndexOf("---", 3);
    if (yamlEndIndex == -1)
    {
        throw new InvalidOperationException("Invalid YAML front matter");
    }

    // 提取 YAML 部分
    var yaml = content.Substring(3, yamlEndIndex - 3).Trim();

    // 提取 Markdown 内容
    var markdownContent = content.Substring(yamlEndIndex + 3).Trim();

    // 解析 YAML（简单实现，生产环境建议使用 YamlDotNet）
    var fields = ParseYaml(yaml);

    // 构建 TodoIndex 对象
    var todo = new TodoIndex
    {
        Id = fields.GetValueOrDefault("id")?.ToString() ?? throw new InvalidOperationException("Missing id"),
        Title = fields.GetValueOrDefault("title")?.ToString(),
        CreatedAt = fields.GetValueOrDefault("createdAt")?.ToString() ?? DateTime.UtcNow.ToString("O"),
        UpdatedAt = fields.GetValueOrDefault("updatedAt")?.ToString() ?? DateTime.UtcNow.ToString("O"),
        Deleted = fields.GetValueOrDefault("deleted")?.ToString()?.ToLower() == "true" ? 1 : 0,
        DeletedAt = fields.GetValueOrDefault("deletedAt")?.ToString(),
        FilePath = filePath,
        FileModifiedAt = new FileInfo(filePath).LastWriteTimeUtc.ToString("O")
    };

    // 移除系统字段，剩余的作为扩展字段
    var extendedFields = fields
        .Where(f => !new[] { "id", "title", "createdAt", "updatedAt", "deleted", "deletedAt" }.Contains(f.Key))
        .ToDictionary(f => f.Key, f => f.Value);

    todo.Fields = JsonSerializer.Serialize(extendedFields);

    return todo;
}

private Dictionary<string, object> ParseYaml(string yaml)
{
    var fields = new Dictionary<string, object>();

    foreach (var line in yaml.Split('\n'))
    {
        var trimmed = line.Trim();
        if (string.IsNullOrEmpty(trimmed)) continue;

        var colonIndex = trimmed.IndexOf(':');
        if (colonIndex == -1) continue;

        var key = trimmed.Substring(0, colonIndex).Trim();
        var value = trimmed.Substring(colonIndex + 1).Trim();

        // 移除引号
        if (value.StartsWith("\"") && value.EndsWith("\""))
        {
            value = value.Substring(1, value.Length - 2);
        }

        fields[key] = value;
    }

    return fields;
}
```

### 建议使用 YamlDotNet 库

```csharp
// 安装 NuGet 包
// dotnet add package YamlDotNet

using YamlDotNet.Serialization;

private Dictionary<string, object> ParseYaml(string yaml)
{
    var deserializer = new DeserializerBuilder().Build();
    return deserializer.Deserialize<Dictionary<string, object>>(yaml);
}
```
