# 5. 数据模型

### 5.1 数据库表结构

#### 表 1: `TodoIndex`

**用途**: 存储 TODO 的索引数据，用于快速查询

```sql
CREATE TABLE TodoIndex (
    Id TEXT PRIMARY KEY,                  -- GUID
    Title TEXT NOT NULL,                  -- 标题
    Status TEXT NOT NULL,                 -- todo/in_progress/done/blocked
    Priority TEXT NOT NULL,               -- low/medium/high/urgent
    CreatedAt TEXT NOT NULL,              -- ISO 8601 格式
    CompletedAt TEXT,                     -- ISO 8601 格式，可为 null
    ProjectId TEXT,                       -- 外键，关联 ProjectIndex
    FilePath TEXT NOT NULL,               -- Markdown 文件路径
    FileModifiedAt TEXT NOT NULL,         -- 文件修改时间，用于验证
    Type TEXT DEFAULT 'todo'              -- todo / project
);

CREATE INDEX idx_status ON TodoIndex(Status);
CREATE INDEX idx_priority ON TodoIndex(Priority);
CREATE INDEX idx_project ON TodoIndex(ProjectId);
CREATE INDEX idx_created ON TodoIndex(CreatedAt);
```

#### 表 2: `ShareToken`

**用途**: 存储分享链接的配置

```sql
CREATE TABLE ShareToken (
    Token TEXT PRIMARY KEY,               -- GUID
    FilterJson TEXT NOT NULL,             -- JSON 格式的过滤条件
    CreatedAt TEXT NOT NULL,              -- 创建时间
    CreatedBy TEXT DEFAULT 'admin'        -- MVP 固定为 admin
);
```

### 5.2 Markdown 文件结构

#### 目录结构

```
data/
├── todos/
│   ├── 3fa85f64-5717-4562-b3fc-2c963f66afa6.md
│   ├── 7b8c9d0e-1234-5678-90ab-cdef12345678.md
│   └── ...
└── projects/
    ├── 1a2b3c4d-5678-90ab-cdef-1234567890ab.md
    └── ...
```

#### 文件命名规则

- 文件名 = `{id}.md`
- `id` 为 GUID 格式（带连字符）
- 扩展名固定为 `.md`

#### YAML Front Matter 规范

```yaml
---
id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
title: 实现 TODO 创建功能
status: in_progress
priority: high
createdAt: 2025-11-16T10:30:00Z
completedAt: null
projectId: 1a2b3c4d-5678-90ab-cdef-1234567890ab
type: todo
---
```

**字段说明**:
- 所有日期时间使用 ISO 8601 格式（UTC）
- `completedAt` 未完成时为字符串 `"null"`（不是空值）
- `projectId` 无项目时为字符串 `"null"`
- YAML 块前后必须有 `---` 分隔符