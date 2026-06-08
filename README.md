# 🏋️ 智能健身房管理系统

基于 **Spring Boot + Vue 3 + MySQL** 的全栈健身房管理系统，提供会员管理、教练管理、课程管理、器材管理及预定等功能。

---

## 📋 功能模块

| 模块 | 功能说明 |
|------|----------|
| **用户认证** | JWT 令牌认证，支持管理员、教练、会员三种角色 |
| **会员管理** | 会员信息增删改查、分页显示、软删除 |
| **教练管理** | 教练信息管理 |
| **课程管理** | 课程信息管理 |
| **课程预定** | 课程排期查看、在线预定课程 |
| **器材管理** | 器材信息管理 |
| **器材监控** | 模拟实时监控器材状态 |
| **数据看板** | ECharts 图表展示运营统计 |

---

## 🛠 技术栈

### 后端

| 框架 / 工具 | 版本 |
|-------------|------|
| Java | 17 |
| Spring Boot | 3.2.5 |
| Spring Security + JWT | — |
| MyBatis | 注解方式 |
| MySQL | 8.0+ |
| Redis | 7.0+（缓存与会话管理） |
| Maven | 3.8+ |

### 前端

| 框架 / 工具 | 版本 |
|-------------|------|
| Vue.js | 3.4+ |
| TypeScript | — |
| Element Plus | 2.7+ |
| Pinia | 2.1+ |
| Vue Router | 4.3+ |
| Axios | — |
| ECharts | 6.0+ |
| Vite | 5.2+ |

---

## 📁 项目结构

```
智能健身房管理系统/
├── backend/                          # Spring Boot 后端
│   ├── src/main/java/com/example/gym/
│   │   ├── auth/                     # 用户登录认证
│   │   ├── booking/                  # 课程预定
│   │   ├── coach/                    # 教练管理
│   │   ├── course/                   # 课程管理
│   │   ├── equipment/                # 器材管理
│   │   ├── member/                   # 会员管理
│   │   ├── system/                   # 系统用户
│   │   ├── security/                 # JWT + Spring Security
│   │   ├── config/                   # 全局配置
│   │   ├── common/                   # 公共组件（统一响应、异常处理）
│   │   └── dev/                      # 开发数据初始化
│   ├── src/main/resources/
│   │   ├── application.yml           # 应用配置
│   │   ├── schema.sql                # 数据库表结构
│   │   └── data.sql                  # 初始化数据
│   ├── pom.xml
│   └── start-backend.bat
│
├── frontend/                         # Vue 3 前端
│   ├── src/
│   │   ├── views/
│   │   │   ├── Login.vue             # 登录页
│   │   │   ├── Dashboard.vue          # 数据看板
│   │   │   ├── layouts/MainLayout.vue # 主布局
│   │   │   ├── member/MemberList.vue  # 会员管理
│   │   │   ├── coach/CoachList.vue    # 教练管理
│   │   │   ├── course/CourseList.vue  # 课程管理
│   │   │   ├── booking/               # 课程预定
│   │   │   └── equipment/             # 器材管理
│   │   ├── router/index.ts           # 路由配置
│   │   ├── utils/request.ts          # Axios 封装
│   │   ├── mock/index.ts             # 本地 Mock 数据
│   │   └── styles/global.scss        # 全局样式
│   ├── package.json
│   └── vite.config.mts
│
├── schema.sql                        # 完整数据库结构
├── seed-data.sql                     # 种子数据
├── scripts/                          # 辅助脚本
└── README.md
```

---

## 🚀 快速开始

### 环境要求

- JDK 17+
- MySQL 8.0+
- Redis 7.0+
- Node.js 18+
- Maven 3.8+

### 1️⃣ 数据库配置

创建数据库并执行初始化脚本：

```sql
CREATE DATABASE gym_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

修改 `backend/src/main/resources/application.yml` 中的数据库连接信息：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/gym_db
    username: root
    password: your_password
```

> 启动后端时会自动执行 `schema.sql` 和 `data.sql` 初始化表结构和数据。

### 2️⃣ 启动 Redis

确保 Redis 服务已启动（默认端口 6379）。

### 3️⃣ 启动后端

```bash
cd backend
mvn clean package -DskipTests
java -jar target/gym-management-backend-1.0.0.jar
```

后端启动在 **http://localhost:18080**

也可以双击 `start-backend.bat` 一键启动。

### 4️⃣ 启动前端

```bash
cd frontend
npm install
npm run dev
```

前端启动在 **http://localhost:5173**

也可以双击 `start-frontend.bat` 一键启动。

### 5️⃣ 默认账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | 123456 | 管理员 |
| coach1 | 123456 | 教练 |
| member1 | 123456 | 会员 |

---

## 🔌 API 接口

### 认证
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/login` | 用户登录 |

### 会员管理
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/members` | 获取所有会员 |
| GET | `/api/members/page` | 分页获取会员 |
| GET | `/api/members/{id}` | 获取会员详情 |
| POST | `/api/members` | 新增会员 |
| PUT | `/api/members/{id}` | 更新会员 |
| DELETE | `/api/members/{id}` | 删除会员 |

其他模块接口风格一致：教练 `/api/coaches`、课程 `/api/courses`、器材 `/api/equipments`、预定 `/api/bookings`。

---

## 🔒 安全设计

- JWT 令牌认证，请求头携带 `Authorization: Bearer <token>`
- Spring Security 权限控制
- BCrypt 密码加密存储
- 软删除机制，保留数据完整性
- 全局异常统一处理
- 统一 API 响应格式 (`ApiResponse`)

---

## 🧪 开发建议

- 后端使用 IntelliJ IDEA，开启热部署：`mvn spring-boot:run`
- 前端使用 VS Code，Vite 热重载即时生效
- 数据库变更时同步更新 `schema.sql` 和 `data.sql`
- 前端开发可启用 `src/mock/index.ts` 本地 Mock 数据

---

## 📄 许可证

本项目仅供毕业设计学习使用。
