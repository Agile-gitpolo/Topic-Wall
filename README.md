> 🏆 **TopicWall —— 你的 Reddit 话题浏览神器！** 
 
🚀 TopicWall 项目说明

---

## 🧱 技术栈一览

- 🖥️ **前端**：React (JSX) + Vite + Tailwind CSS
- 🛠️ **后端**：Ruby on Rails 8
- 🗄️ **数据库**：PostgreSQL
- ⚡ **缓存系统**：Redis
- ⏱️ **任务队列**：Sidekiq
- 🌐 **数据来源**：Reddit API（支持代理 & OAuth2）

---

## 💎 Ruby 版本

- 推荐 Ruby **3.2.3** 及以上
- 查看 `.ruby-version` 文件确保一致

---

## 📦 系统依赖

- Node.js >= 18.x
- Yarn 或 npm
- PostgreSQL >= 13
- Redis >= 6
- ImageMagick（如需处理图片）

---

## ⚙️ 配置（Configuration）

1. **克隆项目**
   ```bash
   git clone https://github.com/yourname/topic_wall.git
   cd topic_wall
   ```
2. **安装 Ruby 依赖**
   ```bash
   bundle install
   ```
3. **安装前端依赖**
   ```bash
   cd vite-project
   npm install
   cd ..
   ```
4. **环境变量配置**
   - 复制 `.env.example` 为 `.env`，并填写：
     ```env
     REDDIT_CLIENT_ID=xxx
     REDDIT_CLIENT_SECRET=xxx
     REDDIT_USERNAME=你的Reddit用户名
     USER_AGENT=linux:topic_wall:0.1 (by /u/你的Reddit用户名)
     PROXY_URL=http://你的代理:端口 # 如有需要
     DATABASE_URL=postgres://your_db_user:your_db_password@localhost:5432/topic_wall_usage
     REDIS_URL=redis://localhost:6379/1
     ```

---

## 🗄️ 数据库创建与初始化

1. **创建数据库**
   ```bash
   rails db:create
   rails db:migrate
   ```
2. **（可选）导入初始数据**
   ```bash
   rails db:seed
   ```

---

## 🧪 测试套件运行

- 运行所有测试：
  ```bash
  bundle exec rspec
  # 或
  rails test
  ```

---

## 🛠️ 服务说明

- **Web 服务**：Rails + Vite 前端
- **任务队列**：Sidekiq（需 Redis 支持）
- **缓存**：Redis
- **定时任务**：见 `sidekiq.yml`/`FetchHotPostsWorker`/`CleanupWorker`
- **API 数据源**：Reddit（OAuth2 + 代理）

---

## 🚀 启动与开发

1. **开发环境一键启动**
   ```bash
   ./start.sh
   # 或分别启动：
   rails s
   cd vite-project && npm run dev
   ```
2. **访问**：
   - 前端：http://localhost:5173
   - 后端：http://localhost:3000

---

## 📦 部署说明（Deployment）

- 推荐平台：Railway、Render、Heroku、Kamal、Docker
- **环境变量**通过平台后台配置，不上传 `.env` 到仓库
- 生产环境建议用 Nginx/SSL 反向代理
- 详见 `Dockerfile`、`Procfile.dev`、`config/deploy.yml`

---

## 💡 其他重要说明

- **安全**：请勿上传 `.env`、`config/master.key`、数据库文件等敏感内容
- **版权声明**：本项目所有代码受版权保护，禁止未授权复制、剽窃、商用
- **贡献**：欢迎 issue/PR，建议先联系作者沟通
- **文档**：详见 `Project Technical Architecture and Functional Process.md`

---

