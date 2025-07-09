#!/bin/bash

echo "🚀 启动 Topic Wall 项目..."

# 检查是否在正确的目录
if [ ! -f "Gemfile" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

echo "📦 检查依赖..."
bundle install

echo "🗄️ 检查数据库..."
rails db:migrate

echo "🔧 检查 Redis 连接..."
if ! redis-cli ping > /dev/null 2>&1; then
    echo "⚠️ 警告：Redis 可能未运行，请确保 Redis 服务已启动"
fi

echo "🌐 启动 Rails 服务器..."
echo "📱 访问地址：http://localhost:3000"
echo "🛑 按 Ctrl+C 停止服务器"
echo ""

rails server 