# 5. 数据模型

### 5.1 数据库表结构

#### 表 1: `TodoIndex`

**用途**: 存储 TODO 的索引数据，用于快速查询

```sql
CREATE TABLE TodoIndex (
    Id TEXT PRIMARY KEY,                  -- GUID
    Title TEXT,                           -- 标题，可为 null（默认使用 id）
    CreatedAt TEXT NOT NULL,              -- ISO 8601 格式，YAML 中维护
    UpdatedAt TEXT NOT NULL,              -- ISO 8601 格式，YAML 中维护
    Deleted INTEGER DEFAULT 0,            -- 软删除标记，0=未删除，1=已删除
    DeletedAt TEXT,                       -- 删除时间，ISO 8601 格式
    Fields TEXT,                          -- JSON 格式，存储所有扩展字段
    FilePath TEXT NOT NULL,               -- Markdown 文件路径
    FileModifiedAt TEXT NOT NULL          -- 文件修改时间，用于同步检测
);

CREATE INDEX idx_created ON TodoIndex(CreatedAt);
CREATE INDEX idx_updated ON TodoIndex(UpdatedAt);
CREATE INDEX idx_deleted ON TodoIndex(Deleted);
```

### 5.2 Markdown 文件结构

#### 目录结构

```
data/
└── todos/
    ├── 3fa85f64-5717-4562-b3fc-2c963f66afa6.md
    ├── 7b8c9d0e-1234-5678-90ab-cdef12345678.md
    └── ...
```

#### 文件命名规则

- 文件名 = `{id}.md`
- `id` 为 GUID 格式（带连字符）
- 扩展名固定为 `.md`

#### YAML Front Matter 规范

**未删除的 TODO 示例**:
```yaml
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
```

**已删除的 TODO 示例**:
```yaml
---
id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
title: 实现 TODO 创建功能
createdAt: 2025-11-17T10:00:00Z
updatedAt: 2025-11-17T15:30:00Z
deleted: true
deletedAt: 2025-11-17T16:00:00Z
status: done
priority: high
project: SlowPoke
---
```

**字段说明**:
- **核心字段**: `id`（必须）、`title`（可选，默认使用id）
- **系统字段**: `createdAt`、`updatedAt`（必须）；`deleted`、`deletedAt`（仅删除时添加）
- **扩展字段**: `status`、`priority`、`project`、`tags` 等，用户可自定义任意字段
- 所有日期时间使用 ISO 8601 格式（UTC）
- YAML 块前后必须有 `---` 分隔符