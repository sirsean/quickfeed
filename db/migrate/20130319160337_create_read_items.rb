class CreateReadItems < ActiveRecord::Migration
  def change
    create_table :read_items, :id => false do |t|
      t.integer :item_id
      t.integer :user_id

      t.timestamps
    end

    add_index :read_items, [:item_id, :user_id], :unique => true
  end
end
