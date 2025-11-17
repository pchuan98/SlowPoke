# 前端 - List 视图 User Stories

## US-201: List 视图页面结构

**作为** 用户
**我需要** 一个清晰的列表页面
**以便** 查看所有 TODO

### 验收标准

- [ ] 页面路由：`/`（主页）
- [ ] 包含页头（标题 + 登出按钮）
- [ ] 包含 TODO 列表区域
- [ ] 包含新建按钮
- [ ] 响应式布局（使用 Tailwind CSS）

### 技术要点

```tsx
// HomePage.tsx
import { useEffect } from 'react';
import { useNavigate } from 'react-router'; // React Router v7
import { useTodoStore } from '@/stores/todoStore'; // Zustand v5
import { LogoutButton } from '@/components/LogoutButton';
import { TodoList } from '@/components/TodoList';
import { Button } from '@/components/ui/button';
import { Plus } from 'lucide-react';

export default function HomePage() {
  const navigate = useNavigate();
  const { todos, fetchTodos, loading } = useTodoStore();

  useEffect(() => {
    fetchTodos();
  }, [fetchTodos]);

  return (
    <div className="container mx-auto p-4">
      {/* 页头 */}
      <header className="flex items-center justify-between mb-6">
        <h1 className="text-3xl font-bold">SlowPoke</h1>
        <LogoutButton />
      </header>

      {/* 新建按钮 */}
      <div className="mb-4">
        <Button onClick={() => navigate('/todos/new')}>
          <Plus className="mr-2 h-4 w-4" />
          新建 TODO
        </Button>
      </div>

      {/* TODO 列表 */}
      {loading ? (
        <div className="text-center py-8">加载中...</div>
      ) : (
        <TodoList todos={todos} />
      )}
    </div>
  );
}
```

---

## US-202: 调用 GET /api/todos 获取列表

**作为** 前端应用
**我需要** 调用 API 获取 TODO 列表
**以便** 显示给用户

### 验收标准

- [ ] 使用 Axios 调用 `/api/todos`
- [ ] 支持分页参数
- [ ] 支持排序参数
- [ ] 使用 Zustand 管理状态

### 技术要点

```typescript
// stores/todoStore.ts
import { create } from 'zustand'; // Zustand v5
import axios from 'axios';

interface Todo {
  id: string;
  title: string;
  fields: Record<string, any>;
  createdAt: string;
  updatedAt: string;
}

interface TodoStore {
  todos: Todo[];
  total: number;
  loading: boolean;
  page: number;
  pageSize: number;
  sortBy: 'createdAt' | 'updatedAt';
  sortOrder: 'asc' | 'desc';

  fetchTodos: () => Promise<void>;
  setPage: (page: number) => void;
  setSorting: (sortBy: string, sortOrder: string) => void;
}

export const useTodoStore = create<TodoStore>((set, get) => ({
  todos: [],
  total: 0,
  loading: false,
  page: 1,
  pageSize: 20,
  sortBy: 'createdAt',
  sortOrder: 'desc',

  fetchTodos: async () => {
    set({ loading: true });
    try {
      const { page, pageSize, sortBy, sortOrder } = get();
      const response = await axios.get('/api/todos', {
        params: { page, pageSize, sortBy, sortOrder }
      });
      set({
        todos: response.data.items,
        total: response.data.total,
        loading: false
      });
    } catch (error) {
      console.error('Failed to fetch todos:', error);
      set({ loading: false });
    }
  },

  setPage: (page) => {
    set({ page });
    get().fetchTodos();
  },

  setSorting: (sortBy, sortOrder) => {
    set({ sortBy, sortOrder });
    get().fetchTodos();
  }
}));
```

---

## US-203: 展示 TODO 列表（标题 + 创建时间）

**作为** 用户
**我需要** 看到 TODO 的基本信息
**以便** 快速浏览任务

### 验收标准

- [ ] 显示 TODO 标题
- [ ] 显示创建时间（格式化为相对时间）
- [ ] 使用 shadcn/ui Card 组件
- [ ] 空列表时显示提示

### 技术要点

```tsx
// components/TodoList.tsx
import { Card, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { formatDistanceToNow } from 'date-fns';
import { zhCN } from 'date-fns/locale';

interface TodoListProps {
  todos: Todo[];
}

export function TodoList({ todos }: TodoListProps) {
  if (todos.length === 0) {
    return (
      <div className="text-center py-12 text-muted-foreground">
        暂无 TODO，点击"新建 TODO"开始记录
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {todos.map((todo) => (
        <Card key={todo.id} className="cursor-pointer hover:shadow-md transition">
          <CardHeader>
            <CardTitle>{todo.title}</CardTitle>
            <CardDescription>
              创建于 {formatDistanceToNow(new Date(todo.createdAt), {
                addSuffix: true,
                locale: zhCN
              })}
            </CardDescription>
          </CardHeader>
        </Card>
      ))}
    </div>
  );
}
```

---

## US-204: 显示扩展字段徽章（status/priority/project）

**作为** 用户
**我需要** 看到 TODO 的状态和属性
**以便** 快速识别任务类型

### 验收标准

- [ ] status 显示为彩色徽章
- [ ] priority 显示优先级图标
- [ ] project 显示项目名称
- [ ] 使用 shadcn/ui Badge 组件

### 技术要点

```tsx
// components/TodoCard.tsx
import { Badge } from '@/components/ui/badge';
import { Star, AlertCircle } from 'lucide-react';

const statusColors = {
  todo: 'bg-gray-200 text-gray-800',
  in_progress: 'bg-blue-200 text-blue-800',
  done: 'bg-green-200 text-green-800',
  blocked: 'bg-red-200 text-red-800'
};

const priorityIcons = {
  high: <Star className="h-4 w-4 text-red-500" />,
  medium: <Star className="h-4 w-4 text-yellow-500" />,
  low: <Star className="h-4 w-4 text-gray-400" />
};

export function TodoCard({ todo }: { todo: Todo }) {
  const { status, priority, project } = todo.fields;

  return (
    <Card className="cursor-pointer hover:shadow-md transition">
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>{todo.title}</CardTitle>
          {priority && priorityIcons[priority as keyof typeof priorityIcons]}
        </div>

        <div className="flex items-center gap-2 mt-2">
          {status && (
            <Badge className={statusColors[status as keyof typeof statusColors]}>
              {status}
            </Badge>
          )}
          {project && (
            <Badge variant="outline">{project}</Badge>
          )}
        </div>

        <CardDescription>
          创建于 {formatDistanceToNow(new Date(todo.createdAt), {
            addSuffix: true,
            locale: zhCN
          })}
        </CardDescription>
      </CardHeader>
    </Card>
  );
}
```

---

## US-205: 默认按 createdAt 降序

**作为** 用户
**我希望** 默认看到最新的 TODO
**以便** 关注最近的任务

### 验收标准

- [ ] 默认排序：`sortBy=createdAt`
- [ ] 默认顺序：`sortOrder=desc`
- [ ] 最新创建的 TODO 在最前面

### 技术要点

```typescript
// Zustand store 默认值
export const useTodoStore = create<TodoStore>((set, get) => ({
  sortBy: 'createdAt',
  sortOrder: 'desc',
  // ...
}));
```

---

## US-206: 支持切换排序方式

**作为** 用户
**我想要** 切换排序方式
**以便** 按不同维度查看任务

### 验收标准

- [ ] 提供排序下拉菜单
- [ ] 支持按创建时间/更新时间排序
- [ ] 支持升序/降序切换

### 技术要点

```tsx
// components/SortSelector.tsx
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useTodoStore } from '@/stores/todoStore';

export function SortSelector() {
  const { sortBy, sortOrder, setSorting } = useTodoStore();

  return (
    <div className="flex gap-2">
      <Select
        value={sortBy}
        onValueChange={(value) => setSorting(value, sortOrder)}
      >
        <SelectTrigger className="w-32">
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="createdAt">创建时间</SelectItem>
          <SelectItem value="updatedAt">更新时间</SelectItem>
        </SelectContent>
      </Select>

      <Select
        value={sortOrder}
        onValueChange={(value) => setSorting(sortBy, value)}
      >
        <SelectTrigger className="w-24">
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="desc">降序</SelectItem>
          <SelectItem value="asc">升序</SelectItem>
        </SelectContent>
      </Select>
    </div>
  );
}
```

---

## US-207: 新建 TODO 按钮

**作为** 用户
**我需要** 一个明显的新建按钮
**以便** 快速创建 TODO

### 验收标准

- [ ] 按钮位于列表上方
- [ ] 显示"新建 TODO"文字和加号图标
- [ ] 点击跳转到 `/todos/new`

### 技术要点

```tsx
import { Button } from '@/components/ui/button';
import { Plus } from 'lucide-react';
import { useNavigate } from 'react-router';

export function NewTodoButton() {
  const navigate = useNavigate();

  return (
    <Button onClick={() => navigate('/todos/new')}>
      <Plus className="mr-2 h-4 w-4" />
      新建 TODO
    </Button>
  );
}
```

---

## US-208: 点击 TODO 进入详情/编辑页

**作为** 用户
**我想要** 点击 TODO 查看详情
**以便** 阅读和编辑内容

### 验收标准

- [ ] 点击 TODO 卡片跳转到 `/todos/{id}`
- [ ] 使用 React Router v7 导航
- [ ] 显示加载指示器

### 技术要点

```tsx
import { useNavigate } from 'react-router';

export function TodoCard({ todo }: { todo: Todo }) {
  const navigate = useNavigate();

  const handleClick = () => {
    navigate(`/todos/${todo.id}`);
  };

  return (
    <Card onClick={handleClick} className="cursor-pointer hover:shadow-md transition">
      {/* Card 内容 */}
    </Card>
  );
}
```

---

## US-209: 快速删除按钮

**作为** 用户
**我想要** 在列表中快速删除 TODO
**以便** 不需要进入详情页

### 验收标准

- [ ] TODO 卡片上显示删除图标按钮
- [ ] 悬停时显示
- [ ] 点击后触发删除确认对话框

### 技术要点

```tsx
import { Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';

export function TodoCard({ todo }: { todo: Todo }) {
  const [showDelete, setShowDelete] = useState(false);
  const deleteTodo = useTodoStore((state) => state.deleteTodo);

  return (
    <Card
      onMouseEnter={() => setShowDelete(true)}
      onMouseLeave={() => setShowDelete(false)}
      className="relative"
    >
      {showDelete && (
        <Button
          variant="ghost"
          size="icon"
          className="absolute top-2 right-2"
          onClick={(e) => {
            e.stopPropagation(); // 防止触发卡片点击
            // 打开删除确认对话框
          }}
        >
          <Trash2 className="h-4 w-4 text-red-500" />
        </Button>
      )}
      {/* Card 内容 */}
    </Card>
  );
}
```

---

## US-210: 删除确认对话框

**作为** 用户
**我需要** 在删除前确认
**以便** 避免误删

### 验收标准

- [ ] 点击删除按钮后弹出确认对话框
- [ ] 显示"确定要删除这个 TODO 吗？"
- [ ] 提供"取消"和"确认"按钮
- [ ] 使用 shadcn/ui AlertDialog 组件

### 技术要点

```tsx
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { useState } from 'react';
import axios from 'axios';
import { useToast } from '@/hooks/use-toast';

export function DeleteTodoDialog({
  todoId,
  onDeleted
}: {
  todoId: string;
  onDeleted: () => void;
}) {
  const [open, setOpen] = useState(false);
  const { toast } = useToast();

  const handleDelete = async () => {
    try {
      await axios.delete(`/api/todos/${todoId}`);
      toast({
        title: '删除成功',
        description: 'TODO 已被删除',
      });
      onDeleted();
    } catch (error) {
      toast({
        variant: 'destructive',
        title: '删除失败',
        description: '请稍后重试',
      });
    }
  };

  return (
    <>
      <Button onClick={() => setOpen(true)}>
        <Trash2 className="h-4 w-4" />
      </Button>

      <AlertDialog open={open} onOpenChange={setOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>确认删除</AlertDialogTitle>
            <AlertDialogDescription>
              确定要删除这个 TODO 吗？此操作可以通过查看已删除项恢复。
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>取消</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete}>
              确认删除
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
```

### Zustand Store 删除操作

```typescript
// stores/todoStore.ts
export const useTodoStore = create<TodoStore>((set, get) => ({
  // ...
  deleteTodo: async (id: string) => {
    try {
      await axios.delete(`/api/todos/${id}`);
      // 重新获取列表
      await get().fetchTodos();
    } catch (error) {
      console.error('Failed to delete todo:', error);
      throw error;
    }
  }
}));
```
