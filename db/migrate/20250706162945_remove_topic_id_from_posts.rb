class RemoveTopicIdFromPosts < ActiveRecord::Migration[8.0]
  def change
    remove_column :posts, :topic_id, :integer
    change_column_null :posts, :topic_id, true
  end
end
