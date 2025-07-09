# lib/reddit_fetcher.rb
# 用于抓取 Reddit 上指定话题的热门帖子，并存入数据库

require 'net/http'
require 'uri'
require 'json'
require 'active_support/core_ext/string'  # 支持 String#truncate
require 'logger'

class RedditFetcher
  CLIENT_ID = ENV['REDDIT_CLIENT_ID']
  CLIENT_SECRET = ENV['REDDIT_CLIENT_SECRET']
  USER_AGENT = ENV['USER_AGENT'] || "linux:topic_wall:0.1 (by /u/#{ENV['REDDIT_USERNAME']})"

  # 获取 Reddit API access_token
  def self.get_access_token
    url = URI.parse('https://www.reddit.com/api/v1/access_token')
    req = Net::HTTP::Post.new(url)
    req.basic_auth(CLIENT_ID, CLIENT_SECRET)
    req.set_form_data({'grant_type' => 'client_credentials'})
    req['User-Agent'] = USER_AGENT

    res = Net::HTTP.start(url.host, url.port, use_ssl: true) { |http| http.request(req) }
    return nil unless res.is_a?(Net::HTTPSuccess)

    JSON.parse(res.body)['access_token']
  rescue => e
    Rails.logger.error("RedditFetcher 获取 token 错误: #{e.message}")
    nil
  end

  # 通用方法：带 token 请求 Reddit API
  def self.reddit_api_get(path)
    reddit_uri = URI("https://oauth.reddit.com#{path}")
    proxy_url = ENV['PROXY_URL']
    if proxy_url
      proxy_uri = URI.parse(proxy_url)
      proxy_addr = proxy_uri.host
      proxy_port = proxy_uri.port
      Rails.logger.info "🌐 [RedditFetcher] 使用代理 #{proxy_addr}:#{proxy_port}"
    else
      proxy_addr = nil
      proxy_port = nil
      Rails.logger.info "🌐 [RedditFetcher] 未设置代理"
    end
    http = Net::HTTP::Proxy(proxy_addr, proxy_port).new(reddit_uri.host, reddit_uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(reddit_uri)
    request['User-Agent'] = USER_AGENT
    access_token = get_access_token
    if access_token
      request['Authorization'] = "bearer #{access_token}"
    else
      Rails.logger.error "❌ [RedditFetcher] 获取 access_token 失败"
      return nil
    end
    response = http.request(request)
    Rails.logger.info "⬅️ [RedditFetcher] Reddit 返回状态码: #{response.code}"
    response
  rescue => e
    Rails.logger.error "🔥 [RedditFetcher] reddit_api_get 异常：#{e.class} - #{e.message}"
    nil
  end

  def self.fetch_hot_posts(topic_name)
    Rails.logger.info "🔍 [RedditFetcher] 正在抓取 Reddit 热门内容：#{topic_name}"
    response = reddit_api_get("/r/#{topic_name}/hot.json?limit=100")
    return [] unless response&.is_a?(Net::HTTPSuccess)
    json = JSON.parse(response.body)
    unless json["data"] && json["data"]["children"]
      Rails.logger.warn "⚠️ [RedditFetcher] Reddit 数据结构异常：缺少 data 或 children 字段"
      return []
    end
    posts = json["data"]["children"].map do |child|
      data = child["data"]
      {
        title: data["title"],
        content: data["selftext"],
        permalink: "https://www.reddit.com#{data["permalink"]}",
        thumbnail: data["thumbnail"],
        created_utc: data["created_utc"]
      }
    end
    Rails.logger.info "📦 [RedditFetcher] 共解析 #{posts.length} 条帖子"
    posts
  rescue => e
    Rails.logger.error "🔥 [RedditFetcher] fetch_hot_posts 异常：#{e.class} - #{e.message}"
    []
  end

  def self.fetch_best_posts(topic_name)
    Rails.logger.info "🔍 [RedditFetcher] 正在抓取 Reddit best 内容：#{topic_name}"
    response = reddit_api_get("/r/#{topic_name}/best.json?limit=100")
    return [] unless response&.is_a?(Net::HTTPSuccess)
    json = JSON.parse(response.body)
    unless json["data"] && json["data"]["children"]
      Rails.logger.warn "⚠️ [RedditFetcher] Reddit 数据结构异常：缺少 data 或 children 字段"
      return []
    end
    posts = json["data"]["children"].map do |child|
      data = child["data"]
      {
        title: data["title"],
        content: data["selftext"],
        permalink: "https://www.reddit.com#{data["permalink"]}",
        thumbnail: data["thumbnail"],
        created_utc: data["created_utc"]
      }
    end
    Rails.logger.info "📦 [RedditFetcher] 共解析 #{posts.length} 条帖子"
    posts
  rescue => e
    Rails.logger.error "🔥 [RedditFetcher] fetch_best_posts 异常：#{e.class} - #{e.message}"
    []
  end

  def self.fetch_new_posts(topic_name)
    Rails.logger.info "🔍 [RedditFetcher] 正在抓取 Reddit new 内容：#{topic_name}"
    response = reddit_api_get("/r/#{topic_name}/new.json?limit=100")
    return [] unless response&.is_a?(Net::HTTPSuccess)
    json = JSON.parse(response.body)
    unless json["data"] && json["data"]["children"]
      Rails.logger.warn "⚠️ [RedditFetcher] Reddit 数据结构异常：缺少 data 或 children 字段"
      return []
    end
    posts = json["data"]["children"].map do |child|
      data = child["data"]
      {
        title: data["title"],
        content: data["selftext"],
        permalink: "https://www.reddit.com#{data["permalink"]}",
        thumbnail: data["thumbnail"],
        created_utc: data["created_utc"]
      }
    end
    Rails.logger.info "📦 [RedditFetcher] 共解析 #{posts.length} 条帖子"
    posts
  rescue => e
    Rails.logger.error "🔥 [RedditFetcher] fetch_new_posts 异常：#{e.class} - #{e.message}"
    []
  end

  # 保存 Reddit 热门帖子到数据库
  def self.fetch_and_save_hot_posts(topic)
    Rails.logger.info "📥 [RedditFetcher] 正在保存 Reddit 热门内容：#{topic.name}"
    posts = fetch_hot_posts(topic.name)

    if posts.blank?
      Rails.logger.warn "⚠️ [RedditFetcher] 无 Reddit 热门帖子可保存"
      return []
    end

    saved_posts = []

    Post.transaction do
      posts.each do |post_data|
        post = Post.find_or_initialize_by(permalink: post_data[:permalink])
        post.title = post_data[:title]
        post.content = post_data[:content]
        post.thumbnail = post_data[:thumbnail] if post_data[:thumbnail]&.start_with?('http')
        post.created_utc = Time.at(post_data[:created_utc].to_f).utc if post_data[:created_utc]
        post.save!
        # 多对多关联
        post.topics << topic unless post.topics.exists?(topic.id)
        Rails.logger.info "💾 [RedditFetcher] 保存帖子: #{post.title} (#{post.permalink}) 关联话题: #{post.topics.map(&:name).join(',')}"
        saved_posts << post
      end
    end

    Rails.logger.info "✅ [RedditFetcher] 成功保存 #{saved_posts.size} 条帖子"
    saved_posts
  rescue => e
    Rails.logger.error "🔥 [RedditFetcher] fetch_and_save_hot_posts 异常：#{e.class} - #{e.message}"
    []
  end

  def self.fetch_and_save_best_posts(topic)
    Rails.logger.info "📥 [RedditFetcher] 正在保存 Reddit best 内容：#{topic.name}"
    posts = fetch_best_posts(topic.name)

    if posts.blank?
      Rails.logger.warn "⚠️ [RedditFetcher] 无 Reddit best 帖子可保存"
      return []
    end

    saved_posts = []

    Post.transaction do
      posts.each do |post_data|
        post = Post.find_or_initialize_by(permalink: post_data[:permalink])
        post.title = post_data[:title]
        post.content = post_data[:content]
        post.thumbnail = post_data[:thumbnail] if post_data[:thumbnail]&.start_with?('http')
        post.created_utc = Time.at(post_data[:created_utc].to_f).utc if post_data[:created_utc]
        post.save!
        # 多对多关联
        post.topics << topic unless post.topics.exists?(topic.id)
        Rails.logger.info "💾 [RedditFetcher] 保存帖子: #{post.title} (#{post.permalink}) 关联话题: #{post.topics.map(&:name).join(',')}"
        saved_posts << post
      end
    end

    Rails.logger.info "✅ [RedditFetcher] 成功保存 #{saved_posts.size} 条帖子"
    saved_posts
  rescue => e
    Rails.logger.error "🔥 [RedditFetcher] fetch_and_save_best_posts 异常：#{e.class} - #{e.message}"
    []
  end

  def self.fetch_and_save_new_posts(topic)
    Rails.logger.info "📥 [RedditFetcher] 正在保存 Reddit new 内容：#{topic.name}"
    posts = fetch_new_posts(topic.name)

    if posts.blank?
      Rails.logger.warn "⚠️ [RedditFetcher] 无 Reddit new 帖子可保存"
      return []
    end

    saved_posts = []

    Post.transaction do
      posts.each do |post_data|
        post = Post.find_or_initialize_by(permalink: post_data[:permalink])
        post.title = post_data[:title]
        post.content = post_data[:content]
        post.thumbnail = post_data[:thumbnail] if post_data[:thumbnail]&.start_with?('http')
        post.created_utc = Time.at(post_data[:created_utc].to_f).utc if post_data[:created_utc]
        post.save!
        # 多对多关联
        post.topics << topic unless post.topics.exists?(topic.id)
        Rails.logger.info "💾 [RedditFetcher] 保存帖子: #{post.title} (#{post.permalink}) 关联话题: #{post.topics.map(&:name).join(',')}"
        saved_posts << post
      end
    end

    Rails.logger.info "✅ [RedditFetcher] 成功保存 #{saved_posts.size} 条帖子"
    saved_posts
  rescue => e
    Rails.logger.error "🔥 [RedditFetcher] fetch_and_save_new_posts 异常：#{e.class} - #{e.message}"
    []
  end
end