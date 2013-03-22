class FeedName < ActiveRecord::Base
  attr_accessible :feed_id, :name, :user_id
  belongs_to :feed
end
