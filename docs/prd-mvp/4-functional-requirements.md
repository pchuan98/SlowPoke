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
- `deleted` - 删除时添加到YAML，值为 true
- `deletedAt` - 删除时添加到YAML，记录删除时间

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