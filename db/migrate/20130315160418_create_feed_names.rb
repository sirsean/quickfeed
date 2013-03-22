class CreateFeedNames < ActiveRecord::Migration
  def change
    create_table :feed_names do |t|
      t.integer :feed_id
      t.integer :user_id
      t.string :name

      t.timestamps
    end

    add_index :feed_names, :feed_id
    add_index :feed_names, :user_id
    add_index :feed_names, [:feed_id, :user_id], :unique => true
  end
end
