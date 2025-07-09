🚀 项目技术架构 & 功能流程总览
🧱 一、技术栈一览
🖥️ 前端：React (JSX) + Vite + Tailwind CSS

🛠️ 后端：Ruby on Rails 8

🗄️ 数据库：PostgreSQL

⚡ 缓存系统：Redis

⏱️ 任务队列 & 定时任务：Sidekiq

🌐 数据来源：Reddit API（通过代理抓取）

🔁 二、核心功能流程
1️⃣ 前端页面（React）
🧱 首页是一个「话题墙」，可以输入关键词，快速搜索 Reddit 上的热门话题。

🔥 模式切换：支持 best / hot / new 三种浏览模式。

🕘 本地存储搜索历史，支持一键点击历史记录再次搜索。

🧭 每个话题卡片都能点进帖子详情页，支持帖子内二次关键词搜索。

⏳ 帖子时间展示支持「相对时间」或「年月日时间」两种格式切换。

2️⃣ 前后端怎么协作？
前端通过 fetch 向 Rails 后端发起请求，API 统一返回 JSON 格式数据：

🔍 /topics/search?keyword=xxx&mode=best|hot|new
👉 搜索 Reddit 话题和对应的帖子

🧵 /topics/:id/posts
👉 获取某个话题下的所有帖子内容

3️⃣ 后端逻辑拆解（Rails）
📌 TopicsController
search
支持 多个关键词 搜索，优先查 Redis 缓存，没命中就爬 Reddit，然后异步刷新缓存。

posts
获取话题下所有帖子，支持关键词过滤 & 排序功能。

🧵 PostsController
fetch
根据话题 ID 抓取最新的 Reddit 帖子，存数据库，再返回前端。

🧠 工具类
RedisHelper
Redis 统一操作封装，支持 JSON 读写缓存。

RedditFetcher
通过代理访问 Reddit API，解析内容 & 存入数据库。

4️⃣ 数据库结构概览 🗂️
表名	描述	字段
topics	话题表	id, name, created_at, updated_at
posts	帖子表	id, title, content, thumbnail, permalink, created_utc, created_at, updated_at
posts_topics	多对多关联表	post_id, topic_id, created_at, updated_at

5️⃣ 缓存 & 异步任务系统 💡
🧊 Redis
缓存关键词 + 模式下的帖子列表，减轻 Reddit 请求压力。

🔄 FetchHotPostsWorker
定时刷新所有话题的「热门帖子」缓存。

🧹 CleanupWorker
每天清理 7 天前的旧帖子，保持数据库干净高效。

👣 三、用户操作全流程体验
👀 用户打开首页，输入关键词 + 模式（best/hot/new），点击搜索。

🔗 前端请求 /topics/search，后台优先查 Redis：

✅ 如果命中缓存：直接返回数据，快！

❌ 如果没命中：实时抓取 Reddit → 存数据库 → 写入缓存 → 返回结果。

🧭 用户点开话题卡片，跳转 /topics/:id/posts，查看该话题下的所有帖子。

🔎 支持本地帖子内搜索、时间格式切换、点击跳转原帖等功能。

🛠️ 后台定时任务自动维护热门话题缓存 & 清除过期数据。

✨ 四、总结：这个项目做了什么？
这个平台就像是一个精致的 Reddit 话题浏览器 📚✨，具备：

🚀 极速缓存支持

⏳ 异步数据抓取

🧹 定时任务维护

🖥️ 现代化的前端体验

🧩 后端结构清晰、易于拓展