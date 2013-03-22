class CreateFeedGroupJoinTable < ActiveRecord::Migration
  def up
    create_table :feeds_groups, :id => false do |t|
      t.integer :feed_id
      t.integer :group_id
    end

    add_index :feeds_groups, [:feed_id, :group_id]
  end

  def down
    drop_table :feeds_groups
  end
end
