# 🚀 Topic Wall 快速启动指南

cd topic_wall
source ~/.bashrc

echo $http_proxy
echo $https_proxy

curl -x http://172.19.64.1:7897 https://api.ipify.org
curl -x http://172.19.64.1:7897 https://www.reddit.com/.json

ping www.reddit.com
ping www.baidu.com

## 一键启动
```bash
./start.sh
```

## 手动启动步骤

### 1. 检查环境
```bash
# 确保在项目根目录
ls Gemfile

# 检查 Ruby 版本
ruby -v

# 检查 Rails 版本
rails -v
```

### 2. 安装依赖
```bash
# 安装 Ruby gems
bundle install

# 安装 Node.js 依赖（如果需要）
npm install
```

### 3. 数据库设置
```bash
# 运行数据库迁移
rails db:migrate

# 检查数据库状态
rails db:migrate:status
```

### 4. 启动服务
```bash
# 启动 Rails 服务器
rails server

# 或指定端口
rails server -p 3000
```

### 5. 访问应用
打开浏览器访问：http://localhost:3000

## 🔧 常见问题

### Redis 连接问题
```bash
# 检查 Redis 是否运行
redis-cli ping

# 启动 Redis（如果需要）
sudo service redis-server start
```

### 数据库问题
```bash
# 重置数据库（谨慎使用）
rails db:reset

# 查看数据库日志
tail -f log/development.log
```

### 端口占用
```bash
# 查看端口占用
lsof -i :3000

# 使用其他端口
rails server -p 3001
```

## 📱 功能验证

启动后测试以下功能：
1. ✅ 首页话题搜索（best/hot/new 模式）
2. ✅ 话题卡片点击进入帖子列表
3. ✅ 帖子列表搜索过滤
4. ✅ 帖子时间显示（相对时间 + 绝对时间）

## 🛠️ 开发模式

```bash
# 启动开发服务器（自动重载）
rails server

# 查看实时日志
tail -f log/development.log
``` 