# 帖子模型
# 字段：title:string, content:text, thumbnail:string, permalink:string, topic_id:integer
# 关联：每个帖子属于一个话题
class Post < ApplicationRecord
  has_many :posts_topics
  has_many :topics, through: :posts_topics
end 