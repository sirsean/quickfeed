class ChangeEntryUrlFromStringToText < ActiveRecord::Migration
  def change
    change_column :items, :url, :text
  end
end
