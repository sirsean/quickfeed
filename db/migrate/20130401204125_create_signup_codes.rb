class CreateSignupCodes < ActiveRecord::Migration
  def change
    create_table :signup_codes do |t|
      t.string :code

      t.timestamps
    end

    add_index :signup_codes, :code, :unique => true
  end
end
