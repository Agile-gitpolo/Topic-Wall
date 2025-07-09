class PostsController < ApplicationController
  # GET /posts/fetch?topic_id=1
  # 根据 topic_id 抓取 Reddit 热门帖子，存入数据库并返回 json
   def fetch
    Rails.logger.info "➡️ [PostsController#fetch] 收到抓取请求，参数: #{params.inspect}"
    topic = Topic.find_by(id: params[:topic_id])
    unless topic
      Rails.logger.warn "❌ [PostsController#fetch] 未找到对应话题: #{params[:topic_id]}"
      render json: { error: '未找到对应话题' }, status: 404 and return
    end
    
  begin
      posts = RedditFetcher.fetch_and_save_hot_posts(topic)
      Rails.logger.info "✅ [PostsController#fetch] 成功抓取并保存 #{posts.size} 条帖子"
      render json: posts.as_json(only: [:id, :title, :content, :thumbnail, :permalink, :topic_id])
    rescue => e
      Rails.logger.error "🔥 [PostsController#fetch] 抓取 Reddit 帖子失败: #{e.class} - #{e.message}"
      render json: { error: '抓取 Reddit 帖子失败' }, status: 500
    end
  end
end