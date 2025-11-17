# 前端 - Markdown 编辑器 User Stories

## US-301: TODO 详情/编辑页面结构

**作为** 用户
**我需要** 一个编辑页面
**以便** 创建和编辑 TODO

### 验收标准

- [ ] 新建路由：`/todos/new`
- [ ] 编辑路由：`/todos/:id`
- [ ] 包含返回按钮
- [ ] 包含保存按钮
- [ ] 响应式布局

### 技术要点

```tsx
// pages/TodoEditor.tsx
import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router'; // React Router v7
import axios from 'axios';
import { Button } from '@/components/ui/button';
import { ArrowLeft, Save } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

export default function TodoEditorPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { toast } = useToast();

  const [title, setTitle] = useState('');
  const [fields, setFields] = useState<Record<string, any>>({});
  const [content, setContent] = useState('');
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const isNewTodo = id === 'new';

  // 加载 TODO 详情（编辑模式）
  useEffect(() => {
    if (!isNewTodo && id) {
      loadTodo(id);
    }
  }, [id]);

  const loadTodo = async (todoId: string) => {
    setLoading(true);
    try {
      const response = await axios.get(`/api/todos/${todoId}`);
      const todo = response.data;
      setTitle(todo.title);
      setFields(todo.fields);
      setContent(todo.content);
    } catch (error) {
      toast({
        variant: 'destructive',
        title: '加载失败',
        description: '无法加载 TODO 详情',
      });
      navigate('/');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      if (isNewTodo) {
        await axios.post('/api/todos', { title, fields, content });
        toast({ title: '创建成功' });
      } else {
        await axios.patch(`/api/todos/${id}`, { title, fields, content });
        toast({ title: '保存成功' });
      }
      navigate('/');
    } catch (error) {
      toast({
        variant: 'destructive',
        title: '保存失败',
        description: '请稍后重试',
      });
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="container mx-auto p-4">加载中...</div>;
  }

  return (
    <div className="container mx-auto p-4 max-w-4xl">
      {/* 顶部按钮 */}
      <div className="flex items-center justify-between mb-4">
        <Button variant="ghost" onClick={() => navigate('/')}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          返回
        </Button>
        <Button onClick={handleSave} disabled={saving}>
          <Save className="mr-2 h-4 w-4" />
          {saving ? '保存中...' : '保存'}
        </Button>
      </div>

      {/* 编辑器内容 */}
      <div className="space-y-4">
        {/* 标题、字段、Markdown 编辑器将在此处 */}
      </div>
    </div>
  );
}
```

---

## US-302: 集成 @uiw/react-md-editor

**作为** 开发者
**我需要** 集成 Markdown 编辑器
**以便** 用户编辑 Markdown 内容

### 验收标准

- [ ] 安装 `@uiw/react-md-editor` v4.0.8
- [ ] 集成到编辑页面
- [ ] 支持所见即所得编辑
- [ ] 支持语法高亮

### 技术要点

```bash
# 安装依赖
npm install @uiw/react-md-editor@^4.0.8
```

```tsx
// components/MarkdownEditor.tsx
import MDEditor from '@uiw/react-md-editor'; // v4.0.8

interface MarkdownEditorProps {
  value: string;
  onChange: (value?: string) => void;
}

export function MarkdownEditor({ value, onChange }: MarkdownEditorProps) {
  return (
    <div data-color-mode="light">
      <MDEditor
        value={value}
        onChange={onChange}
        height={500}
        preview="edit" // 默认编辑模式
        hideToolbar={false}
        enableScroll={true}
        visibleDragbar={true}
      />
    </div>
  );
}
```

### @uiw/react-md-editor v4 新特性

- 更新到 rehype-sanitize v6
- 更新到 rehype v13
- 改进的 TypeScript 类型定义
- 更好的性能优化

---

## US-303: 标题输入框

**作为** 用户
**我需要** 输入 TODO 标题
**以便** 快速描述任务

### 验收标准

- [ ] 使用 shadcn/ui Input 组件
- [ ] 标题为可选（留空则使用 id）
- [ ] placeholder 提示
- [ ] 自动聚焦（新建时）

### 技术要点

```tsx
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export function TitleInput({
  value,
  onChange
}: {
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <div className="space-y-2">
      <Label htmlFor="title">标题（可选）</Label>
      <Input
        id="title"
        type="text"
        placeholder="为空时将使用 ID 作为标题"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        autoFocus
      />
    </div>
  );
}
```

---

## US-304: 扩展字段表单（status/priority/project/tags）

**作为** 用户
**我需要** 设置 TODO 的属性
**以便** 分类和组织任务

### 验收标准

- [ ] 提供常用字段输入：status、priority、project、tags
- [ ] 使用 shadcn/ui Select 组件
- [ ] 支持自定义字段
- [ ] 字段可选

### 技术要点

```tsx
// components/TodoFieldsForm.tsx
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface TodoFieldsFormProps {
  fields: Record<string, any>;
  onChange: (fields: Record<string, any>) => void;
}

export function TodoFieldsForm({ fields, onChange }: TodoFieldsFormProps) {
  const updateField = (key: string, value: any) => {
    onChange({ ...fields, [key]: value });
  };

  return (
    <div className="grid grid-cols-2 gap-4">
      {/* Status */}
      <div className="space-y-2">
        <Label>状态</Label>
        <Select
          value={fields.status || ''}
          onValueChange={(value) => updateField('status', value)}
        >
          <SelectTrigger>
            <SelectValue placeholder="选择状态" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="todo">待办</SelectItem>
            <SelectItem value="in_progress">进行中</SelectItem>
            <SelectItem value="done">已完成</SelectItem>
            <SelectItem value="blocked">阻塞</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Priority */}
      <div className="space-y-2">
        <Label>优先级</Label>
        <Select
          value={fields.priority || ''}
          onValueChange={(value) => updateField('priority', value)}
        >
          <SelectTrigger>
            <SelectValue placeholder="选择优先级" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="high">高</SelectItem>
            <SelectItem value="medium">中</SelectItem>
            <SelectItem value="low">低</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Project */}
      <div className="space-y-2">
        <Label>项目</Label>
        <Input
          placeholder="项目名称"
          value={fields.project || ''}
          onChange={(e) => updateField('project', e.target.value)}
        />
      </div>

      {/* Tags */}
      <div className="space-y-2">
        <Label>标签</Label>
        <Input
          placeholder="使用逗号分隔"
          value={fields.tags?.join(', ') || ''}
          onChange={(e) => {
            const tags = e.target.value
              .split(',')
              .map((t) => t.trim())
              .filter(Boolean);
            updateField('tags', tags);
          }}
        />
      </div>
    </div>
  );
}
```

---

## US-305: Markdown 内容编辑区

**作为** 用户
**我需要** 编辑 Markdown 内容
**以便** 记录详细信息

### 验收标准

- [ ] 使用 @uiw/react-md-editor
- [ ] 高度：500px
- [ ] 支持拖拽调整高度
- [ ] 支持全屏模式

### 技术要点

```tsx
import MDEditor from '@uiw/react-md-editor';

export function TodoEditorPage() {
  const [content, setContent] = useState('');

  return (
    <div className="space-y-4">
      {/* ... 标题和字段 ... */}

      <div className="space-y-2">
        <Label>内容</Label>
        <div data-color-mode="light">
          <MDEditor
            value={content}
            onChange={(val) => setContent(val || '')}
            height={500}
            preview="edit"
            hideToolbar={false}
            enableScroll={true}
            visibleDragbar={true}
            fullscreen={true}
          />
        </div>
      </div>
    </div>
  );
}
```

---

## US-306: 实时预览 Markdown 渲染

**作为** 用户
**我需要** 实时预览 Markdown 效果
**以便** 确认格式正确

### 验收标准

- [ ] 编辑器默认显示编辑模式
- [ ] 支持切换预览模式（edit/preview/live）
- [ ] 实时渲染 Markdown
- [ ] 支持 GFM（GitHub Flavored Markdown）

### 技术要点

```tsx
import MDEditor from '@uiw/react-md-editor';

export function MarkdownEditor({ value, onChange }: MarkdownEditorProps) {
  const [previewMode, setPreviewMode] = useState<'edit' | 'live' | 'preview'>('edit');

  return (
    <div data-color-mode="light">
      {/* 预览模式切换 */}
      <div className="mb-2 flex gap-2">
        <Button
          variant={previewMode === 'edit' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setPreviewMode('edit')}
        >
          编辑
        </Button>
        <Button
          variant={previewMode === 'live' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setPreviewMode('live')}
        >
          实时预览
        </Button>
        <Button
          variant={previewMode === 'preview' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setPreviewMode('preview')}
        >
          预览
        </Button>
      </div>

      <MDEditor
        value={value}
        onChange={onChange}
        height={500}
        preview={previewMode}
        hideToolbar={false}
        enableScroll={true}
        visibleDragbar={true}
      />
    </div>
  );
}
```

---

## US-307: 保存按钮 - 调用 POST /api/todos（新建）

**作为** 用户
**我想要** 保存新建的 TODO
**以便** 记录任务

### 验收标准

- [ ] 点击保存按钮调用 `POST /api/todos`
- [ ] 发送 title、fields、content
- [ ] 成功后显示提示并跳转列表页
- [ ] 失败后显示错误提示

### 技术要点

```tsx
const handleSave = async () => {
  setSaving(true);
  try {
    const response = await axios.post('/api/todos', {
      title: title || undefined,
      fields,
      content
    });

    toast({
      title: '创建成功',
      description: `TODO "${response.data.title}" 已创建`,
    });

    navigate('/');
  } catch (error) {
    toast({
      variant: 'destructive',
      title: '创建失败',
      description: '请检查输入并重试',
    });
  } finally {
    setSaving(false);
  }
};
```

---

## US-308: 保存按钮 - 调用 PATCH /api/todos/{id}（编辑）

**作为** 用户
**我想要** 保存编辑后的 TODO
**以便** 更新任务信息

### 验收标准

- [ ] 点击保存按钮调用 `PATCH /api/todos/{id}`
- [ ] 发送修改的字段
- [ ] 成功后显示提示并跳转列表页
- [ ] 失败后显示错误提示

### 技术要点

```tsx
const handleSave = async () => {
  setSaving(true);
  try {
    if (isNewTodo) {
      await axios.post('/api/todos', { title, fields, content });
      toast({ title: '创建成功' });
    } else {
      await axios.patch(`/api/todos/${id}`, { title, fields, content });
      toast({ title: '保存成功' });
    }
    navigate('/');
  } catch (error) {
    toast({
      variant: 'destructive',
      title: isNewTodo ? '创建失败' : '保存失败',
      description: '请稍后重试',
    });
  } finally {
    setSaving(false);
  }
};
```

---

## US-309: 保存成功提示

**作为** 用户
**我需要** 看到保存成功的提示
**以便** 确认操作完成

### 验收标准

- [ ] 使用 shadcn/ui Toast 组件
- [ ] 显示"创建成功"或"保存成功"
- [ ] 自动消失（3 秒）

### 技术要点

```tsx
import { useToast } from '@/hooks/use-toast';

const { toast } = useToast();

toast({
  title: '保存成功',
  description: 'TODO 已更新',
});
```

---

## US-310: 保存失败错误提示

**作为** 用户
**我需要** 看到保存失败的提示
**以便** 知道出了什么问题

### 验收标准

- [ ] 使用 shadcn/ui Toast 组件
- [ ] 显示错误信息
- [ ] 红色警告样式

### 技术要点

```tsx
toast({
  variant: 'destructive',
  title: '保存失败',
  description: error.response?.data?.message || '请稍后重试',
});
```

---

## US-311: 返回列表按钮

**作为** 用户
**我需要** 一个返回按钮
**以便** 放弃编辑并返回列表

### 验收标准

- [ ] 按钮位于页面左上角
- [ ] 显示左箭头图标 + "返回"文字
- [ ] 点击跳转到 `/`
- [ ] 不保存当前编辑

### 技术要点

```tsx
import { ArrowLeft } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useNavigate } from 'react-router';

export function BackButton() {
  const navigate = useNavigate();

  return (
    <Button variant="ghost" onClick={() => navigate('/')}>
      <ArrowLeft className="mr-2 h-4 w-4" />
      返回
    </Button>
  );
}
```

### 可选：未保存提示

```tsx
const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

const handleBack = () => {
  if (hasUnsavedChanges) {
    if (confirm('有未保存的修改，确定要离开吗？')) {
      navigate('/');
    }
  } else {
    navigate('/');
  }
};
```
