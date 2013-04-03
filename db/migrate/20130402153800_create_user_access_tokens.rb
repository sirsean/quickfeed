class CreateUserAccessTokens < ActiveRecord::Migration
  def change
    create_table :user_access_tokens do |t|
      t.integer :user_id
      t.string :app
      t.string :token

      t.timestamps
    end

    add_index :user_access_tokens, :user_id
    add_index :user_access_tokens, [:user_id, :app], :unique => true
  end
end
