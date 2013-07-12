class AddErrorsToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :num_errors, :integer, :default => 0
  end
end
