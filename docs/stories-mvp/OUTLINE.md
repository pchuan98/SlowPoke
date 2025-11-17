# Stories MVP - 大纲

---

## 1. 部署基础

- [ ] US-001: Docker 单容器部署
- [ ] US-002: 数据目录持久化（data/）
- [ ] US-003: 配置文件管理（密码、存储路径）
- [ ] US-004: 首次启动初始化

---

## 2. 系统基础

- [ ] US-101: 统一异常处理中间件
- [ ] US-102: 结构化日志（Serilog）
- [ ] US-103: API 统一响应格式

---

## 3. 数据存储架构

### 数据库索引
- [ ] US-201: 创建 TodoIndex 表结构
- [ ] US-202: 创建数据库索引（CreatedAt/UpdatedAt/Deleted）

### Markdown 文件
- [ ] US-211: 创建 data/todos/ 目录结构
- [ ] US-212: 定义 Markdown 文件命名规则（{id}.md）
- [ ] US-213: 定义 YAML Front Matter 格式规范

### 文件同步机制
- [ ] US-221: 启动时扫描 data/todos/，重建索引
- [ ] US-222: 检测外部文件修改（FileModifiedAt 对比）
- [ ] US-223: 外部修改时重新解析文件并更新索引

---

## 4. TODO CRUD - 后端

### 创建
- [ ] US-301: POST /api/todos - 创建 TODO
- [ ] US-302: 生成 GUID 作为 id
- [ ] US-303: 标题可选（为空则使用 id）
- [ ] US-304: 支持扩展字段（status/priority/project/tags 等）
- [ ] US-305: 支持 Markdown 内容
- [ ] US-306: 写入数据库索引
- [ ] US-307: 生成 Markdown 文件（data/todos/{id}.md）

### 读取
- [ ] US-311: GET /api/todos - 获取 TODO 列表
- [ ] US-312: 列表返回 id/title/fields/createdAt/updatedAt（不含 content）
- [ ] US-313: 列表支持分页
- [ ] US-314: 列表支持排序（createdAt/updatedAt）
- [ ] US-315: 列表自动过滤 deleted=true
- [ ] US-316: GET /api/todos/{id} - 获取 TODO 详情
- [ ] US-317: 详情返回完整 content

### 更新
- [ ] US-321: PATCH /api/todos/{id} - 更新 TODO
- [ ] US-322: 支持更新 title
- [ ] US-323: 支持更新扩展字段
- [ ] US-324: 支持更新 content
- [ ] US-325: 自动更新 updatedAt
- [ ] US-326: 同步更新数据库索引
- [ ] US-327: 同步更新 Markdown 文件

### 删除
- [ ] US-331: DELETE /api/todos/{id} - 软删除 TODO
- [ ] US-332: 在 YAML 添加 deleted=true
- [ ] US-333: 在 YAML 添加 deletedAt
- [ ] US-334: 更新数据库 Deleted 和 DeletedAt 字段
- [ ] US-335: 删除操作幂等

---

## 5. 认证系统

- [ ] US-401: POST /api/auth/login - 用户登录
- [ ] US-402: 密码验证（配置文件中的密码）
- [ ] US-403: 设置 Cookie（HttpOnly/Secure/SameSite）
- [ ] US-404: Cookie 有效期 7 天
- [ ] US-405: POST /api/auth/logout - 用户登出
- [ ] US-406: 清除 Cookie
- [ ] US-407: 认证中间件（拦截所有 API 除登录接口）
- [ ] US-408: 未认证时返回 401

---

## 6. 前端 - List 视图

- [ ] US-501: 登录页面（密码输入框）
- [ ] US-502: 登录成功跳转主页
- [ ] US-503: 登录失败显示错误提示
- [ ] US-504: 登出按钮
- [ ] US-505: List 视图页面结构
- [ ] US-506: 调用 GET /api/todos 获取列表
- [ ] US-507: 展示 TODO 列表（标题 + 创建时间）
- [ ] US-508: 显示扩展字段徽章（status/priority/project）
- [ ] US-509: 默认按 createdAt 降序
- [ ] US-510: 支持切换排序方式
- [ ] US-511: 新建 TODO 按钮
- [ ] US-512: 点击 TODO 进入详情/编辑页
- [ ] US-513: 快速删除按钮
- [ ] US-514: 删除确认对话框

---

## 7. 前端 - Markdown 编辑器

- [ ] US-601: TODO 详情/编辑页面结构
- [ ] US-602: 集成 @uiw/react-md-editor
- [ ] US-603: 标题输入框
- [ ] US-604: 扩展字段表单（status/priority/project/tags）
- [ ] US-605: Markdown 内容编辑区
- [ ] US-606: 实时预览 Markdown 渲染
- [ ] US-607: 保存按钮 - 调用 POST /api/todos（新建）
- [ ] US-608: 保存按钮 - 调用 PATCH /api/todos/{id}（编辑）
- [ ] US-609: 保存成功提示
- [ ] US-610: 保存失败错误提示
- [ ] US-611: 返回列表按钮

---

**总计**: 63 个用户故事
