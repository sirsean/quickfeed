class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :url
      t.string :feed_url
      t.string :title

      t.timestamps
    end

    add_index :feeds, :feed_url, :unique => true
  end
end
