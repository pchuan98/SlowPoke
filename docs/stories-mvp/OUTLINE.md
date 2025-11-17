# Stories MVP - 大纲

---

## 1. 认证系统

- [ ] US-001: POST /api/auth/login - 用户登录
- [ ] US-002: 密码验证（配置文件中的密码）
- [ ] US-003: 设置 Cookie（HttpOnly/Secure/SameSite）
- [ ] US-004: Cookie 有效期 7 天
- [ ] US-005: POST /api/auth/logout - 用户登出
- [ ] US-006: 清除 Cookie
- [ ] US-007: 认证中间件（拦截所有 API 除登录接口）
- [ ] US-008: 未认证时返回 401
- [ ] US-009: 登录页面（密码输入框）
- [ ] US-010: 登录成功跳转主页
- [ ] US-011: 登录失败显示错误提示
- [ ] US-012: 登出按钮

---

## 2. TODO CRUD - 后端

### 创建
- [ ] US-101: POST /api/todos - 创建 TODO
- [ ] US-102: 生成 GUID 作为 id
- [ ] US-103: 标题可选（为空则使用 id）
- [ ] US-104: 支持扩展字段（status/priority/project/tags 等）
- [ ] US-105: 支持 Markdown 内容
- [ ] US-106: 写入数据库索引
- [ ] US-107: 生成 Markdown 文件（data/todos/{id}.md）

### 读取
- [ ] US-111: GET /api/todos - 获取 TODO 列表
- [ ] US-112: 列表返回 id/title/fields/createdAt/updatedAt（不含 content）
- [ ] US-113: 列表支持分页
- [ ] US-114: 列表支持排序（createdAt/updatedAt）
- [ ] US-115: 列表自动过滤 deleted=true
- [ ] US-116: GET /api/todos/{id} - 获取 TODO 详情
- [ ] US-117: 详情返回完整 content

### 更新
- [ ] US-121: PATCH /api/todos/{id} - 更新 TODO
- [ ] US-122: 支持更新 title
- [ ] US-123: 支持更新扩展字段
- [ ] US-124: 支持更新 content
- [ ] US-125: 自动更新 updatedAt
- [ ] US-126: 同步更新数据库索引
- [ ] US-127: 同步更新 Markdown 文件

### 删除
- [ ] US-131: DELETE /api/todos/{id} - 软删除 TODO
- [ ] US-132: 在 YAML 添加 deleted=true
- [ ] US-133: 在 YAML 添加 deletedAt
- [ ] US-134: 更新数据库 Deleted 和 DeletedAt 字段
- [ ] US-135: 删除操作幂等

---

## 3. 前端 - List 视图

- [ ] US-201: List 视图页面结构
- [ ] US-202: 调用 GET /api/todos 获取列表
- [ ] US-203: 展示 TODO 列表（标题 + 创建时间）
- [ ] US-204: 显示扩展字段徽章（status/priority/project）
- [ ] US-205: 默认按 createdAt 降序
- [ ] US-206: 支持切换排序方式
- [ ] US-207: 新建 TODO 按钮
- [ ] US-208: 点击 TODO 进入详情/编辑页
- [ ] US-209: 快速删除按钮
- [ ] US-210: 删除确认对话框

---

## 4. 前端 - Markdown 编辑器

- [ ] US-301: TODO 详情/编辑页面结构
- [ ] US-302: 集成 @uiw/react-md-editor
- [ ] US-303: 标题输入框
- [ ] US-304: 扩展字段表单（status/priority/project/tags）
- [ ] US-305: Markdown 内容编辑区
- [ ] US-306: 实时预览 Markdown 渲染
- [ ] US-307: 保存按钮 - 调用 POST /api/todos（新建）
- [ ] US-308: 保存按钮 - 调用 PATCH /api/todos/{id}（编辑）
- [ ] US-309: 保存成功提示
- [ ] US-310: 保存失败错误提示
- [ ] US-311: 返回列表按钮

---

## 5. 数据存储架构

### 数据库索引
- [ ] US-401: 创建 TodoIndex 表结构
- [ ] US-402: 创建数据库索引（CreatedAt/UpdatedAt/Deleted）

### Markdown 文件
- [ ] US-411: 创建 data/todos/ 目录结构
- [ ] US-412: 定义 Markdown 文件命名规则（{id}.md）
- [ ] US-413: 定义 YAML Front Matter 格式规范

### 文件同步机制
- [ ] US-421: 启动时扫描 data/todos/，重建索引
- [ ] US-422: 检测外部文件修改（FileModifiedAt 对比）
- [ ] US-423: 外部修改时重新解析文件并更新索引

---

## 6. 系统基础

- [ ] US-501: 统一异常处理中间件
- [ ] US-502: 结构化日志（Serilog）
- [ ] US-503: API 统一响应格式
- [ ] US-504: 配置文件管理（密码、存储路径）

---

## 7. 部署

- [ ] US-601: Docker 单容器部署
- [ ] US-602: 数据目录持久化（data/）
- [ ] US-603: 首次启动初始化

---

**总计**: 63 个用户故事
