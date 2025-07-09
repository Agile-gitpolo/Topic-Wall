require 'redis_helper'
require 'concurrent'
require 'keyword_helper'

class TopicsController < ApplicationController
  include KeywordHelper
  before_action :set_topic, only: %i[ show edit update destroy ]

  # GET /topics
  # 返回所有话题列表（JSON）
  def index
    topics = Topic.all.order(created_at: :desc)
    render json: topics.as_json(only: [:id, :name, :created_at])
  end

  # GET /topics/search?keyword=ruby,rails,react
  # 支持多个关键词，Redis 缓存，抓取并发优化
  def search
    Rails.logger.info "➡️ [TopicsController#search] 收到搜索请求，参数: #{params.inspect}"
    keywords = params[:keyword].to_s.split(',').map(&:strip).reject(&:blank?).uniq
    mode = params[:mode].to_s == 'hot' ? 'hot' : (params[:mode].to_s == 'new' ? 'new' : 'best')
    Rails.logger.info "🔍 [TopicsController#search] 解析参数: keywords=#{keywords}, mode=#{mode}"

    if keywords.empty?
      Rails.logger.warn "❌ [TopicsController#search] 关键词不能为空"
      return render json: { error: '关键词不能为空' }, status: 400
    end

    results = {}
    errors = {}

    keywords.each do |kw|
      normalized_kw = normalize_keyword(kw)
      cache_key = "reddit_#{normalized_kw}_#{mode}"
      begin
        cached = RedisHelper.get_json(cache_key)
        now = Time.now.to_i

        if cached && cached['data']
          # 判断逻辑过期
      if cached['expires_at'].to_i > now
    Rails.logger.info "✅ [TopicsController#search] 命中有效缓存: #{kw}, expires_at=#{Time.at(cached['expires_at'].to_i)}"
    topic = Topic.find_or_create_by!(name: normalized_kw)
    posts = cached['data']
    results[kw] = {
    topic: topic.as_json(only: [:id, :name]),
    posts: posts
    }
  next
else
  Rails.logger.info "⚠️ [TopicsController#search] 命中过期缓存: #{kw}, expires_at=#{Time.at(cached['expires_at'].to_i)}，异步刷新中"
  topic = Topic.find_or_create_by!(name: normalized_kw)
  posts = cached['data']
  results[kw] = {
    topic: topic.as_json(only: [:id, :name]),
    posts: posts
  }
  RefreshTopicCacheJob.perform_later(normalized_kw, mode)
  next
  end
end

        Rails.logger.info "❌ [TopicsController#search] 未命中缓存: #{kw}，同步拉取并异步写入缓存"
        topic = Topic.lock.find_or_create_by!(name: normalized_kw)
        posts =
          case mode
          when 'hot'
            RedditFetcher.fetch_and_save_hot_posts(topic) || []
          when 'new'
            arr = RedditFetcher.fetch_and_save_new_posts(topic) || []
            arr.sort_by { |p| p.created_utc || p.created_at }.reverse
          else
            RedditFetcher.fetch_and_save_best_posts(topic) || []
          end
        posts_json = posts.as_json(only: [:id, :title, :content, :thumbnail, :permalink, :topic_id, :created_utc])
        results[kw] = {
          topic: topic.as_json(only: [:id, :name]),
          posts: posts_json
        }
        RefreshTopicCacheJob.perform_later(normalized_kw, mode)
        Rails.logger.info "📝 [TopicsController#search] 已同步拉取数据并触发异步缓存写入: #{kw}"
      rescue => e
        Rails.logger.error "❌ [TopicsController#search] 处理关键词 #{kw} 时出错: #{e.class} - #{e.message}"
        Rails.logger.error "❌ [TopicsController#search] 错误堆栈: #{e.backtrace.first(5).join("\n")}"
        errors[kw] = 'Reddit 拉取失败'
      end
    end

    Rails.logger.info "⬅️ [TopicsController#search] 搜索完成，返回结果: #{results.keys}, 错误: #{errors.keys}"
    render json: { results: results, errors: errors }
  end

  # GET /topics/:id/posts
  # 获取某个话题下的所有帖子
  def posts
    topic = Topic.find_by(id: params[:id])
    unless topic
      render json: { error: '未找到话题' }, status: 404 and return
    end
    posts = topic.posts
    if params[:mode] == 'new'
      posts = posts.order(created_utc: :desc, created_at: :desc)
    end
    if params[:search].present?
      keyword = params[:search].to_s
      posts = posts.where('title LIKE ? OR content LIKE ?', "%#{keyword}%", "%#{keyword}%")
    end
    render json: posts.as_json(only: [:id, :title, :content, :thumbnail, :permalink, :topic_id, :created_utc])
  end

  # GET /topics/1 or /topics/1.json
  def show
  end

  # GET /topics/new
  def new
    @topic = Topic.new
  end

  # GET /topics/1/edit
  def edit
  end

  # POST /topics or /topics.json
  def create
    @topic = Topic.new(topic_params)

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, notice: "Topic was successfully created." }
        format.json { render :show, status: :created, location: @topic }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topics/1 or /topics/1.json
  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to @topic, notice: "Topic was successfully updated." }
        format.json { render :show, status: :ok, location: @topic }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1 or /topics/1.json
  def destroy
    @topic.destroy!

    respond_to do |format|
      format.html { redirect_to topics_path, status: :see_other, notice: "Topic was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def self.refresh_topic_cache(keyword, mode)
    normalized_kw = KeywordHelper.normalize_keyword(keyword)
    cache_key = "reddit_#{normalized_kw}_#{mode}"
    topic = Topic.lock.find_or_create_by!(name: normalized_kw)
    posts =
      case mode
      when 'hot'
        RedditFetcher.fetch_and_save_hot_posts(topic) || []
      when 'new'
        RedditFetcher.fetch_and_save_new_posts(topic) || []
      else
        RedditFetcher.fetch_and_save_best_posts(topic) || []
      end
    posts_json = posts.as_json(only: [:id, :title, :content, :thumbnail, :permalink, :topic_id])
    expires_at = (Time.now + 60).to_i
    Rails.logger.info "🟢 [DEBUG] set_json key=#{cache_key} value=#{posts_json.inspect} expires_at=#{expires_at}"
    RedisHelper.set_json(cache_key, { expires_at: expires_at, data: posts_json }, 60)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      @topic = Topic.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def topic_params
      params.require(:topic).permit(:title, :description)
    end
end
