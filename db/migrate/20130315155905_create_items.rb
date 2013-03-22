class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :feed_id
      t.string :title
      t.text :summary
      t.text :content
      t.string :url
      t.string :author
      t.datetime :published_at

      t.timestamps
    end

    add_index :items, :feed_id
    add_index :items, :published_at
  end
end
