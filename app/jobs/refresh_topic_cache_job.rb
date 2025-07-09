require 'keyword_helper'

class RefreshTopicCacheJob < ApplicationJob
  include KeywordHelper
  queue_as :default

  def perform(keyword, mode)
    TopicsController.refresh_topic_cache(keyword, mode)
  end
end
