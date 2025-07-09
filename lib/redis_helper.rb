require 'redis'

module RedisHelper
  # 获取 Redis 实例  
  def self.client
    @client ||= Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')
  end

  # 获取缓存
  def self.get(key)
    Rails.logger.info "✅ [RedisHelper] 命中缓存: #{key}"
    client.get(key)
  rescue => e
    Rails.logger.error "🔥 [RedisHelper] get 异常: #{e.class} - #{e.message}"
    nil
  end
  
  # 写入缓存，带过期时间
  def self.set(key, value, ttl = 60)
    Rails.logger.info "📝 [RedisHelper] 设置缓存: #{key} (ttl: #{ttl})"
    client.set(key, value, ex: ttl)
  rescue => e
    Rails.logger.error "🔥 [RedisHelper] set 异常: #{e.class} - #{e.message}"
  end

  # 增加 JSON 支持
  def self.get_json(key)
    val = get(key)
    val.present? ? JSON.parse(val) : nil
  end

  def self.set_json(key, value, ttl = 60)
    set(key, value.to_json, ttl)
  end
end
