class User < ActiveRecord::Base
  attr_accessible :id, :email, :password, :password_confirmation, :timezone, :username
  has_many :groups

  has_secure_password

  validates :username, 
    :presence => true, 
    :length => { :minimum => 3 }, 
    :uniqueness => { :case_sensitive => false },
    :format => { :with => /^[a-zA-Z0-9_]+$/, :message => "only letters, numbers, and underscores allowed" }

  validates :email,
    :presence => true,
    :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :message => "must be a valid email address" }

  validates :password,
    :length => { :minimum => 8, :if => :validate_password? },
    :confirmation => { :if => :validate_password? }

  private

  def validate_password?
    password.present? || password_confirmation.present?
  end
end
