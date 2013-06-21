class IncreaseContentSize < ActiveRecord::Migration
  def change
    change_column :items, :content, :text, :limit => 16777216
  end
end
