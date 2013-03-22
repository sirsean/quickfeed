class AddOrderToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :index_num, :integer, :default => 0
  end
end
