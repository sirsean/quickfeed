class UserAccessToken < ActiveRecord::Base
  attr_accessible :app, :token, :user_id
  belongs_to :user
end
