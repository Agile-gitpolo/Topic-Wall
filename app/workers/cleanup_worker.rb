class CleanupWorker
  include Sidekiq::Worker

  # 每天凌晨执行
  def perform
    # 删除7天前的帖子
    Post.where('created_at < ?', 7.days.ago).delete_all
    Rails.logger.info "已清理7天前的帖子"
  end
end


class FetchHotPostsWorker
  include Sidekiq::Worker

  # 每隔5分钟执行
  def perform
    Topic.find_each do |topic|
      RedditFetcher.fetch_and_save_hot_posts(topic)
    end
    Rails.logger.info "定时抓取所有话题的 Reddit 热门帖子完成"
  end
end