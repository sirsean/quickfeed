class AddLastFetchedAtToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :last_fetched_at, :datetime, :default => Time.new(2000, 1, 1)
  end
end
