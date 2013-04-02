# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130401204125) do

  create_table "app_versions", :force => true do |t|
    t.integer  "version"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "feed_names", :force => true do |t|
    t.integer  "feed_id"
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "feed_names", ["feed_id", "user_id"], :name => "index_feed_names_on_feed_id_and_user_id", :unique => true
  add_index "feed_names", ["feed_id"], :name => "index_feed_names_on_feed_id"
  add_index "feed_names", ["user_id"], :name => "index_feed_names_on_user_id"

  create_table "feeds", :force => true do |t|
    t.string   "url"
    t.string   "feed_url"
    t.string   "title"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.datetime "last_fetched_at", :default => '2000-01-01 06:00:00'
  end

  add_index "feeds", ["feed_url"], :name => "index_feeds_on_feed_url", :unique => true

  create_table "feeds_groups", :id => false, :force => true do |t|
    t.integer "feed_id"
    t.integer "group_id"
  end

  add_index "feeds_groups", ["feed_id", "group_id"], :name => "index_feeds_groups_on_feed_id_and_group_id"

  create_table "groups", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "public"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "index_num",  :default => 0
  end

  add_index "groups", ["user_id"], :name => "index_groups_on_user_id"

  create_table "items", :force => true do |t|
    t.integer  "feed_id"
    t.string   "title"
    t.text     "summary"
    t.text     "content"
    t.text     "url"
    t.string   "author"
    t.datetime "published_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "items", ["feed_id"], :name => "index_items_on_feed_id"
  add_index "items", ["published_at"], :name => "index_items_on_published_at"

  create_table "read_items", :id => false, :force => true do |t|
    t.integer  "item_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "read_items", ["item_id", "user_id"], :name => "index_read_items_on_item_id_and_user_id", :unique => true

  create_table "signup_codes", :force => true do |t|
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "signup_codes", ["code"], :name => "index_signup_codes_on_code", :unique => true

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password_digest"
    t.string   "email"
    t.string   "timezone",        :default => "Eastern Time (US & Canada)"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
