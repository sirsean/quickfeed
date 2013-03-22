class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :email
      t.string :timezone, :default => "Eastern Time (US & Canada)"

      t.timestamps
    end

    add_index :users, :username, :unique => true
  end
end
