# 话题模型
# 字段：name:string
# 关联：一个话题有多个帖子
class Topic < ApplicationRecord
  has_many :posts_topics
  has_many :posts, through: :posts_topics
end
