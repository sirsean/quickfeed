class Item < ActiveRecord::Base
  attr_accessible :author, :content, :summary, :feed_id, :url, :published_at, :title
  belongs_to :feed
end
