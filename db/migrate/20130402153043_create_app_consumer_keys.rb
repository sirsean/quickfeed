class CreateAppConsumerKeys < ActiveRecord::Migration
  def change
    create_table :app_consumer_keys do |t|
      t.string :app
      t.string :consumer_key

      t.timestamps
    end

    add_index :app_consumer_keys, :app, :unique => true
  end
end
