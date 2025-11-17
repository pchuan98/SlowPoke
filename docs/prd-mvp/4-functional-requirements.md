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
- `id` - GUID，自动生成
- `title` - 标题，可选，为空时默认使用 id 作为标题

**扩展字段**:
- 用户可自定义任意 YAML Front Matter 字段
- 常见示例：status、priority、project、tags、dueDate 等

**Markdown 内容**:
- YAML Front Matter 之后的正文

**文件存储**:
- 路径：`data/todos/{id}.md`
- 创建时间、修改时间由文件系统提供

**交互流程**:
1. 点击"新建 TODO"
2. 填写标题（可选，为空则使用 id）
3. 可选：添加扩展字段
4. 可选：编辑 Markdown 内容
5. 保存生成文件并写入数据库索引

**Markdown 文件示例**:
```markdown
---
id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
title: 实现 TODO 创建功能
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

**功能描述**: 查询和展示 TODO

**API 端点**:
- `GET /api/todos` - 获取 TODO 列表（支持过滤）
- `GET /api/todos/{id}` - 获取单个 TODO 详情

**文件同步逻辑**:
```csharp
1. 从数据库查询 TODO 索引记录
2. 检查文件修改时间：
   - 如果 file.LastWriteTimeUtc == index.FileModifiedAt
     → 数据一致，直接返回数据库数据
   - 如果不一致
     → 文件被外部修改，重新解析 Markdown 文件
     → 更新数据库索引
     → 返回最新数据
```

#### FR-2.3 更新 TODO

**功能描述**: 修改现有 TODO 的任何字段

**交互流程**:
1. 用户点击 TODO 卡片进入编辑页
2. 修改标题、状态、优先级、内容等
3. 点击"保存"
4. 后端同时更新：
   - 数据库索引记录
   - Markdown 文件内容
   - 更新 `fileModifiedAt` 字段
5. 返回列表，显示更新后的内容

#### FR-2.4 删除 TODO

**功能描述**: 删除一个 TODO（软删除或硬删除可配置）

**MVP 实现**: 硬删除（直接删除文件和数据库记录）

**交互流程**:
1. 用户点击"删除"按钮
2. 弹出确认对话框："确定删除该 TODO 吗？此操作不可恢复"
3. 用户确认
4. 后端删除：
   - 数据库记录
   - Markdown 文件
5. 返回列表，移除该 TODO

#### FR-2.5 完成 TODO

**功能描述**: 快速标记 TODO 为已完成

**交互流程**:
1. 用户在列表中点击"完成"按钮（或勾选复选框）
2. 后端更新：
   - `status` → `done`
   - `completedAt` → 当前时间
3. UI 立即更新（乐观更新）

---

### 4.3 项目管理

#### FR-3.1 项目概念

**设计理念**: 项目本质上也是一个 TODO，但：
- 存储在单独的目录 `data/projects/`
- 有特殊的类型标识字段 `type: project`
- 可以被其他 TODO 引用（通过 `projectId`）

**项目特有字段**:
| 字段          | 类型     | 说明               |
| ------------- | -------- | ------------------ |
| `type`        | String   | 固定为 `"project"` |
| `description` | Markdown | 项目描述           |

**Markdown 文件格式**:
```markdown
---
id: 1a2b3c4d-5678-90ab-cdef-1234567890ab
title: SlowPoke 项目
type: project
status: in_progress
priority: high
createdAt: 2025-11-01T00:00:00Z
completedAt: null
---

这是 SlowPoke 项目的描述...

## 项目目标
- 实现个人 TODO 管理
- 支持 Markdown 存储
```

#### FR-3.2 创建项目

**交互流程**:
1. 用户点击"新建项目"按钮
2. 填写项目标题和描述
3. 保存后，创建在 `data/projects/` 目录

#### FR-3.3 TODO 归属项目

**交互流程**:
1. 创建/编辑 TODO 时，显示"所属项目"下拉框
2. 下拉框列出所有项目（从 `data/projects/` 读取）
3. 用户选择项目（或选择"无项目"）
4. 保存时，将 `projectId` 写入 TODO 的 YAML Front Matter

#### FR-3.4 按项目筛选

**功能描述**: 在 TODO 列表中，按项目筛选显示

**交互流程**:
1. 在过滤栏中，显示"项目"下拉框
2. 用户选择项目
3. 列表只显示该项目下的 TODO

---

### 4.4 四种视图

#### FR-4.1 List 视图

**功能描述**: 简单的列表展示，按创建时间倒序排列

**UI 元素**:
- TODO 卡片（标题、状态徽章、优先级标识、创建时间）
- 每个卡片右侧显示操作按钮（编辑、删除、完成）

**排序**: 默认按 `createdAt` 降序

#### FR-4.2 Table 视图

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