class CreatePostsTopicsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :posts_topics, id: false do |t|
      t.references :post, null: false, foreign_key: true
      t.references :topic, null: false, foreign_key: true
      t.timestamps
    end
    add_index :posts_topics, [:post_id, :topic_id], unique: true
  end
end
