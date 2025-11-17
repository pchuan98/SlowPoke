# Stories MVP - 大纲

> 基于 prd-mvp (1-6) 和 brainstroming.md 的用户故事大纲

---

## 🎯 MVP 核心范围

根据 1-product-overview.md，MVP 包含：
1. ✅ 基础 TODO CRUD
2. ✅ 四种展示视图（List、Table、Kanban、Timeline）
3. ✅ Markdown 编辑器（元数据和内容分离）
4. ✅ 项目概念（项目即 TODO）
5. ✅ 灵活的过滤筛选
6. ✅ 单用户 Web 应用
7. ✅ 数据库 + Markdown 双存储架构

---

## 第一阶段：基础能力（已有详细 PRD）

### 🔐 1. 认证系统

- [ ] US-001: 用户登录（密码验证 + Cookie，有效期 7 天）
- [ ] US-002: 用户登出（清除 Cookie）
- [ ] US-003: 未认证拦截（除登录和分享接口外所有 API 需认证）

### 📝 2. TODO 核心操作（CRUD）

**创建**
- [ ] US-101: 创建 TODO（生成 GUID + 创建时间戳）
- [ ] US-102: 标题可选（为空时使用 id 作为默认标题）
- [ ] US-103: 添加扩展字段（status/priority/project/tags 等）
- [ ] US-104: 编辑 Markdown 内容（YAML Front Matter 之后的正文）

**读取**
- [ ] US-111: 获取 TODO 列表（返回 id/title/fields/createdAt/updatedAt，不含 content）
- [ ] US-112: 获取 TODO 详情（含完整 content）
- [ ] US-113: 列表支持分页
- [ ] US-114: 列表支持排序（createdAt/updatedAt 升序/降序）

**更新**
- [ ] US-121: 更新 TODO 标题
- [ ] US-122: 更新扩展字段（部分更新或全量更新）
- [ ] US-123: 更新 Markdown 内容
- [ ] US-124: 自动更新 updatedAt 时间戳

**删除**
- [ ] US-131: 软删除 TODO（添加 deleted=true 和 deletedAt 到 YAML）
- [ ] US-132: 删除前确认对话框
- [ ] US-133: 列表查询自动过滤 deleted=true 的项
- [ ] US-134: 删除操作幂等（多次删除同一 TODO 均返回成功）

### 💾 3. 双存储架构

**数据库索引（SQLite + TodoIndex 表）**
- [ ] US-201: TODO 创建时写入索引（Id/Title/CreatedAt/UpdatedAt/Fields/FilePath/FileModifiedAt）
- [ ] US-202: TODO 更新时同步更新索引
- [ ] US-203: TODO 删除时更新 Deleted 和 DeletedAt 字段
- [ ] US-204: 创建索引（CreatedAt/UpdatedAt/Deleted）

**Markdown 文件存储**
- [ ] US-211: 创建 TODO 时生成文件（data/todos/{id}.md）
- [ ] US-212: 更新 TODO 时同步更新 Markdown 文件
- [ ] US-213: 删除时在 YAML Front Matter 添加 deleted 和 deletedAt 字段
- [ ] US-214: YAML Front Matter 格式规范（id/title/createdAt/updatedAt + 扩展字段）

**文件与数据库同步**
- [ ] US-221: 启动时扫描 data/todos/ 目录，重建索引
- [ ] US-222: 检测外部文件修改（对比 FileModifiedAt 与实际文件时间）
- [ ] US-223: 外部修改时重新解析 YAML + Content，更新索引

### 🎨 4. List 视图

- [ ] US-301: 列表展示 TODO（标题 + 创建时间）
- [ ] US-302: 显示扩展字段徽章（status/priority/project）
- [ ] US-303: 点击 TODO 进入详情/编辑页
- [ ] US-304: 列表中快速删除按钮
- [ ] US-305: 默认按 createdAt 降序排列
- [ ] US-306: 支持切换排序方式（createdAt/updatedAt）

### 📄 5. Markdown 编辑器

- [ ] US-401: 集成 @uiw/react-md-editor（所见即所得）
- [ ] US-402: 实时预览 Markdown 渲染
- [ ] US-403: YAML 扩展字段表单（独立于 Markdown 编辑器）
- [ ] US-404: 表单与 Markdown 内容分离编辑（元数据 vs 正文）

### 🔧 6. 系统功能

- [ ] US-501: 配置文件管理（密码、数据存储路径）
- [ ] US-502: 统一异常处理中间件
- [ ] US-503: 结构化日志（Serilog）
- [ ] US-504: API 统一响应格式（JSON）

### 🚀 7. 部署

- [ ] US-601: Docker 单容器部署
- [ ] US-602: 数据持久化（挂载 data/ 目录）
- [ ] US-603: 首次启动初始化（默认密码提示）

---

## 第二阶段：扩展能力（MVP 范围内，待细化 PRD）

### 📊 8. 多视图展示

**Table 视图**
- [ ] US-701: 表格形式展示 TODO
- [ ] US-702: 支持多列排序
- [ ] US-703: 可自定义显示列（扩展字段）

**Kanban 视图**
- [ ] US-711: 按 status 字段分列展示
- [ ] US-712: 拖拽改变 TODO 状态
- [ ] US-713: 拖拽时自动更新 updatedAt

**Timeline 视图**
- [ ] US-721: 按时间轴展示 TODO
- [ ] US-722: 支持按 createdAt 或 updatedAt 排列
- [ ] US-723: 时间分组（今天、本周、本月、更早）

### 🗂️ 9. 项目管理

- [ ] US-801: 项目作为特殊 TODO（project 类型）
- [ ] US-802: 项目存储在独立目录（data/projects/{id}.md）
- [ ] US-803: TODO 可关联项目（通过 project 字段）
- [ ] US-804: 按项目筛选 TODO 列表

### 🔍 10. 过滤与筛选

- [ ] US-901: 按状态过滤（status 字段）
- [ ] US-902: 按优先级过滤（priority 字段）
- [ ] US-903: 按项目过滤（project 字段）
- [ ] US-904: 按时间范围过滤（createdAt/updatedAt）
- [ ] US-905: 关键词搜索（标题 + 内容全文搜索）
- [ ] US-906: 多条件组合过滤

---

## 💡 核心哲学映射

基于 brainstroming.md，MVP 应体现：

1. ✅ **TODO 是原子单位**
   - 每个 TODO 独立存储为 {id}.md 文件
   - GUID 保证全局唯一性
   - 不依赖任何容器而存在

2. ✅ **TODO 是工作上下文容器**
   - Markdown 内容可记录资料、问题、思考、计划
   - 扩展字段支持任意自定义属性
   - YAML Front Matter 与正文分离

3. ✅ **本地优先存储**
   - 数据库 + Markdown 双存储
   - Markdown 文件是用户可见、可编辑的
   - 外部修改可被检测和同步

4. ✅ **记录为王**
   - 软删除（deleted=true），不物理删除
   - 保留完整的创建和更新时间戳
   - 删除后的 TODO 依然保留在文件中

5. ✅ **数据主权**
   - 用户拥有所有 Markdown 文件
   - 可直接编辑文件，系统自动同步
   - 单用户 Web 应用，无外部依赖

6. ⏳ **关系运算**（MVP 暂不实现）
   - 依赖、阻塞、子任务等关系
   - 在项目管理（US-801-804）中初步体现

7. ⏳ **可扩展平台**（MVP 初步支持）
   - 通过自定义扩展字段实现
   - 未来可扩展为插件机制（MCP 式）

---

## 📝 优先级说明

**P0（第一阶段）- MVP 必需**
- 认证系统（US-001 ~ US-003）
- TODO CRUD（US-101 ~ US-134）
- 双存储架构（US-201 ~ US-223）
- List 视图（US-301 ~ US-306）
- Markdown 编辑器（US-401 ~ US-404）
- 系统功能（US-501 ~ US-504）
- 部署（US-601 ~ US-603）

**P1（第二阶段）- MVP 范围内，可后续迭代**
- Table/Kanban/Timeline 视图（US-701 ~ US-723）
- 项目管理（US-801 ~ US-804）
- 过滤筛选（US-901 ~ US-906）

---

**总计**:
- 第一阶段（P0）：约 35 个核心故事
- 第二阶段（P1）：约 18 个扩展故事
- **MVP 总计：约 53 个用户故事**

**下一步**: 讨论优先级和范围，确定具体实现顺序
