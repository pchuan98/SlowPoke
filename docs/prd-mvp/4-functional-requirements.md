# 4. 功能需求

### 4.1 认证系统

#### FR-1.1 登录
- **用户名**: 固定为 `admin`
- **密码**: 通过配置文件设置，明文存储
- **登录流程**:
  1. 未认证用户访问时跳转登录页
  2. 输入密码验证
  3. 验证通过后设置 Cookie，有效期 7 天
  4. 跳转到主页

- **Cookie 安全配置**:
  - `HttpOnly = true` - 防止 XSS 攻击
  - `Secure = true` - 生产环境仅 HTTPS 传输
  - `SameSite = Strict` - 防止 CSRF 攻击

- **默认配置**: 首次部署提供默认密码，建议用户修改

#### FR-1.2 登出
- 清除 Cookie 并跳转登录页

#### FR-1.3 认证中间件
- 所有 API 端点需要认证
- 例外：`/api/auth/login`、`/api/share/{token}`

---

### 4.2 TODO 管理

#### FR-2.1 创建 TODO

**核心字段**:
- `id` - GUID，系统生成
- `title` - 标题，可选，为空时默认使用 id

**系统字段**（YAML中维护）:
- `createdAt` - 创建时间，创建时生成
- `updatedAt` - 最后修改时间，每次API更新时更新
- `deleted` - 删除标记，仅删除时添加，值为 true
- `deletedAt` - 删除时间，仅删除时添加

**扩展字段**:
- 用户可自定义任意 YAML Front Matter 字段
- 常见示例：status、priority、project、tags、dueDate 等

**Markdown 内容**:
- YAML Front Matter 之后的正文

**文件存储**:
- 路径：`data/todos/{id}.md`
- 文件系统的 modifiedAt 仅用于外部修改检测

**交互流程**:
1. 点击"新建 TODO"
2. 填写标题（可选，为空则使用 id）
3. 可选：添加扩展字段
4. 可选：编辑 Markdown 内容
5. 保存生成文件并写入数据库索引

**Markdown 文件示例（未删除）**:
```markdown
---
id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
title: 实现 TODO 创建功能
createdAt: 2025-11-17T10:00:00Z
updatedAt: 2025-11-17T15:30:00Z
status: in_progress
priority: high
project: SlowPoke
---

详细描述内容...
```

**Markdown 文件示例（已删除）**:
```markdown
---
id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
title: 实现 TODO 创建功能
createdAt: 2025-11-17T10:00:00Z
updatedAt: 2025-11-17T15:30:00Z
deleted: true
deletedAt: 2025-11-17T16:00:00Z
status: in_progress
priority: high
project: SlowPoke
---

详细描述内容...
```

**API 请求**:
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

**API 响应**:
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "title": "实现 TODO 创建功能",
  "fields": {
    "status": "in_progress",
    "priority": "high",
    "project": "SlowPoke"
  },
  "content": "详细描述..."
}
```

#### FR-2.2 读取 TODO

**单个读取**:
- 根据 id 查询数据库索引
- 读取对应 Markdown 文件
- 解析 YAML Front Matter 和正文内容
- 返回完整数据

**列表读取**:
- 返回字段：id、title、fields（所有扩展字段）、createdAt、updatedAt
- 不返回 content（正文内容）
- 支持过滤（基于扩展字段）
- 支持分页
- 支持排序

**文件同步**:
- 对比数据库记录的文件修改时间与实际文件修改时间
- 若不一致，重新解析文件并更新数据库索引

**API 响应 - 单个详情**:
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
  "updatedAt": "2025-11-17T12:00:00Z"
}
```

**API 响应 - 列表**:
```json
{
  "total": 100,
  "items": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "title": "实现 TODO 创建功能",
      "fields": {
        "status": "in_progress",
        "priority": "high",
        "project": "SlowPoke"
      },
      "createdAt": "2025-11-17T10:00:00Z",
      "updatedAt": "2025-11-17T12:00:00Z"
    }
  ]
}
```

#### FR-2.3 更新 TODO

**交互流程**:
1. 点击 TODO 进入编辑页
2. 修改标题、扩展字段、Markdown 内容
3. 保存时同步更新数据库索引和 Markdown 文件

**API 端点**: `PATCH /api/todos/{id}`

**API 请求示例 - 只更新状态**:
```json
{
  "fields": {
    "status": "done"
  }
}
```

**API 请求示例 - 更新多个字段**:
```json
{
  "fields": {
    "status": "done",
    "priority": "medium"
  },
  "content": "更新后的内容..."
}
```

**API 响应**: 同读取详情接口

#### FR-2.4 删除 TODO

**删除方式**: 软删除

**系统字段**:
- `deleted` - 布尔值，默认 false
- `deletedAt` - 删除时间，默认 null

**交互流程**:
1. 点击"删除"按钮
2. 确认对话框
3. 标记 TODO 为已删除（deleted = true，设置 deletedAt）

**并发处理**:
- 使用数据库事务保证原子性
- 删除操作幂等：多次删除同一 TODO 均返回成功

**API 端点**: `DELETE /api/todos/{id}`

**API 响应**:
```json
{
  "success": true,
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
}
```

---

### 4.3 List 视图

**基础展示**:
- title（标题）
- createdAt（创建时间）
- 操作按钮：编辑、删除

**扩展字段显示**:
- 如果 TODO 有 status 字段，显示状态徽章
- 如果有 priority 字段，显示优先级标识
- 如果有 project 字段，显示项目名称
- 其他扩展字段可选择性显示

**排序**:
- 默认按 createdAt 降序
- 支持按 updatedAt 排序

**交互**:
- 点击 TODO 卡片进入编辑页
- 点击"删除"按钮软删除
- 列表自动过滤 deleted = true 的记录

**数据来源**: 调用 `GET /api/todos` 列表接口

---

## Obsolete - 待后续版本实现

以下功能在当前 P0 版本中不实现，标记为 obsolete，待后续版本开发。

### 项目管理

#### 项目概念

**设计理念**: 项目本质上也是一个 TODO，但：
- 存储在单独的目录 `data/projects/`
- 有特殊的类型标识字段 `type: project`
- 可以被其他 TODO 引用（通过 `projectId`）

---

### Table 视图

**功能描述**: 表格展示，支持列排序

**表格列**:
| 列名     | 字段          | 可排序 | 说明           |
| -------- | ------------- | ------ | -------------- |
| 标题     | `title`       | 是     | 点击可进入详情 |
| 状态     | `status`      | 是     | 徽章显示       |
| 优先级   | `priority`    | 是     | 颜色标识       |
| 项目     | `projectId`   | 是     | 显示项目名称   |
| 创建时间 | `createdAt`   | 是     | 格式化显示     |
| 完成时间 | `completedAt` | 是     | 未完成显示"-"  |
| 操作     | -             | 否     | 编辑/删除按钮  |

**交互**:
- 点击列头可排序
- 支持多列筛选（顶部过滤栏）

#### FR-4.3 Kanban 视图

**功能描述**: 看板展示，支持拖拽改变状态

**泳道划分**: 按 `status` 字段分为 4 列
- **待办** (`todo`)
- **进行中** (`in_progress`)
- **已完成** (`done`)
- **阻塞** (`blocked`)

**交互**:
1. TODO 卡片在不同列之间拖拽
2. 拖拽到新列，自动更新 `status` 字段
3. 使用 `@dnd-kit/core` 实现拖拽

**视觉设计**:
- 每列显示 TODO 数量
- 卡片显示标题、优先级、项目名称
- 高优先级卡片高亮显示

#### FR-4.4 Timeline 视图

**功能描述**: 时间线展示，按时间顺序排列

**排序逻辑**:
- 默认按 `createdAt` 降序（最新的在上）
- 可切换为按 `completedAt` 排序（只显示已完成的）

**UI 元素**:
- 时间轴左侧显示时间点
- 右侧显示 TODO 卡片
- 已完成的 TODO 显示绿色标记，未完成显示蓝色

---

### 4.5 过滤与筛选

#### FR-5.1 过滤条件

**支持的过滤维度**:
| 过滤器   | 类型 | 选项                                |
| -------- | ---- | ----------------------------------- |
| 状态     | 多选 | todo / in_progress / done / blocked |
| 优先级   | 多选 | low / medium / high / urgent        |
| 项目     | 单选 | 所有项目 + "无项目"                 |
| 时间范围 | 日期 | 自定义起止日期                      |
| 关键词   | 文本 | 搜索标题和内容                      |

**过滤逻辑**:
- 多个条件之间是 **AND** 关系
- 同一维度的多选是 **OR** 关系
- 示例：状态=`todo` OR `in_progress` AND 项目=`SlowPoke` AND 优先级=`high`

#### FR-5.2 过滤栏 UI

**位置**: 页面顶部，所有视图共享

**交互**:
1. 用户选择过滤条件
2. 实时更新视图（无需点击"应用"按钮）
3. 显示当前匹配的 TODO 数量："共 X 条 TODO"
4. 支持"清除所有过滤"按钮

---

### 4.6 分享功能（MVP 简化版）

#### FR-6.1 分享 URL

**功能描述**: 生成一个只读的分享链接，展示过滤后的 TODO

**实现方式**:
1. 用户设置好过滤条件
2. 点击"分享"按钮
3. 后端生成一个分享 Token（GUID）
4. 将过滤条件 + Token 存储到数据库
5. 返回分享 URL：`https://yourdomain.com/share/{token}`
6. 访问该 URL 的人可以看到只读的 TODO 列表（不需要登录）

**分享链接属性**:
- 只读（不能编辑、删除）
- 永久有效（MVP 不支持过期时间）
- 可以撤销（删除 Token 记录）

---

### 4.7 数据库重建功能

#### FR-7.1 从 Markdown 文件重建索引

**功能描述**: 扫描所有 Markdown 文件，重新生成数据库索引

**使用场景**:
- 数据库损坏
- 外部批量修改了 Markdown 文件
- 迁移数据后首次启动

**交互流程**:
1. 用户点击"重建索引"按钮（设置页或管理页）
2. 弹出确认对话框："将扫描所有 Markdown 文件并重建数据库，继续吗？"
3. 用户确认
4. 后端执行：
   - 清空数据库所有表
   - 扫描 `data/todos/` 和 `data/projects/` 目录
   - 解析每个 `.md` 文件的 YAML Front Matter
   - 插入数据库
   - 更新 `fileModifiedAt` 为文件当前修改时间
5. 完成后显示："成功重建 X 条 TODO，Y 个项目"