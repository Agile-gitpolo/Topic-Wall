class AddCreatedUtcToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :created_utc, :datetime
  end
end
