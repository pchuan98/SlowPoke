# 6. API 设计

### 6.1 认证相关

#### POST `/api/auth/login`

**请求**:
```json
{
  "password": "your-password"
}
```

**响应**:
```json
{
  "success": true,
  "message": "登录成功"
}
```

**状态码**:
- `200 OK` - 登录成功，设置 Cookie
- `401 Unauthorized` - 密码错误

---

#### POST `/api/auth/logout`

**请求**: 无 Body

**响应**:
```json
{
  "success": true,
  "message": "已退出登录"
}
```

**状态码**:
- `200 OK` - 退出成功，清除 Cookie

---

### 6.2 TODO 相关

#### GET `/api/todos`

**描述**: 获取 TODO 列表（支持过滤）

**查询参数**:
| 参数        | 类型     | 必填 | 说明                             |
| ----------- | -------- | ---- | -------------------------------- |
| `status`    | String[] | 否   | 状态筛选，多个用逗号分隔         |
| `priority`  | String[] | 否   | 优先级筛选                       |
| `projectId` | String   | 否   | 项目 ID                          |
| `keyword`   | String   | 否   | 关键词搜索（标题+内容）          |
| `startDate` | String   | 否   | 起始日期（ISO 8601）             |
| `endDate`   | String   | 否   | 结束日期（ISO 8601）             |
| `type`      | String   | 否   | `todo` 或 `project`，默认 `todo` |

**示例**:
```
GET /api/todos?status=todo,in_progress&priority=high&projectId=1a2b3c4d
```

**响应**:
```json
{
  "total": 42,
  "items": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "title": "实现 TODO 创建功能",
      "status": "in_progress",
      "priority": "high",
      "createdAt": "2025-11-16T10:30:00Z",
      "completedAt": null,
      "projectId": "1a2b3c4d-5678-90ab-cdef-1234567890ab",
      "projectName": "SlowPoke 项目",
      "content": "这里是 Markdown 内容..."
    }
  ]
}
```

**状态码**:
- `200 OK` - 成功

---

#### GET `/api/todos/{id}`

**描述**: 获取单个 TODO 详情

**路径参数**:
- `id` - TODO 的 GUID

**响应**:
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "title": "实现 TODO 创建功能",
  "status": "in_progress",
  "priority": "high",
  "createdAt": "2025-11-16T10:30:00Z",
  "completedAt": null,
  "projectId": "1a2b3c4d-5678-90ab-cdef-1234567890ab",
  "content": "# 详细内容\n\n这里是 Markdown..."
}
```

**状态码**:
- `200 OK` - 成功
- `404 Not Found` - TODO 不存在

---

#### POST `/api/todos`

**描述**: 创建新的 TODO

**请求**:
```json
{
  "title": "实现 TODO 创建功能",
  "status": "todo",
  "priority": "high",
  "projectId": "1a2b3c4d-5678-90ab-cdef-1234567890ab",
  "content": "# 详细内容\n\n..."
}
```

**响应**:
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "title": "实现 TODO 创建功能",
  "status": "todo",
  "priority": "high",
  "createdAt": "2025-11-16T10:30:00Z",
  "completedAt": null,
  "projectId": "1a2b3c4d-5678-90ab-cdef-1234567890ab",
  "content": "# 详细内容\n\n..."
}
```

**状态码**:
- `201 Created` - 创建成功
- `400 Bad Request` - 参数错误

---

#### PUT `/api/todos/{id}`

**描述**: 更新现有 TODO

**请求**:
```json
{
  "title": "实现 TODO 创建功能（已完成）",
  "status": "done",
  "priority": "high",
  "completedAt": "2025-11-17T15:00:00Z",
  "projectId": "1a2b3c4d-5678-90ab-cdef-1234567890ab",
  "content": "# 详细内容\n\n..."
}
```

**响应**: 同 GET `/api/todos/{id}`

**状态码**:
- `200 OK` - 更新成功
- `404 Not Found` - TODO 不存在
- `400 Bad Request` - 参数错误

---

#### DELETE `/api/todos/{id}`

**描述**: 删除 TODO（硬删除）

**响应**:
```json
{
  "success": true,
  "message": "TODO 已删除"
}
```

**状态码**:
- `200 OK` - 删除成功
- `404 Not Found` - TODO 不存在

---

### 6.3 项目相关

#### GET `/api/projects`

**描述**: 获取所有项目列表

**响应**:
```json
{
  "total": 5,
  "items": [
    {
      "id": "1a2b3c4d-5678-90ab-cdef-1234567890ab",
      "title": "SlowPoke 项目",
      "status": "in_progress",
      "createdAt": "2025-11-01T00:00:00Z",
      "todoCount": 12
    }
  ]
}
```

---

#### POST `/api/projects`

**描述**: 创建新项目

**请求**:
```json
{
  "title": "新项目",
  "description": "项目描述..."
}
```

**响应**: 同 TODO 创建

---

### 6.4 分享相关

#### POST `/api/share`

**描述**: 创建分享链接

**请求**:
```json
{
  "filter": {
    "status": ["todo", "in_progress"],
    "projectId": "1a2b3c4d-5678-90ab-cdef-1234567890ab"
  }
}
```

**响应**:
```json
{
  "token": "abc123def456",
  "url": "https://yourdomain.com/share/abc123def456"
}
```

---

#### GET `/api/share/{token}`

**描述**: 通过分享链接查看 TODO（无需登录）

**响应**: 同 GET `/api/todos`（只读，应用过滤条件）

---

### 6.5 系统相关

#### POST `/api/system/rebuild-index`

**描述**: 从 Markdown 文件重建数据库索引

**响应**:
```json
{
  "success": true,
  "todosCount": 42,
  "projectsCount": 5,
  "message": "索引重建成功"
}
```

**状态码**:
- `200 OK` - 重建成功
- `500 Internal Server Error` - 重建失败