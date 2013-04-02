class SignupCode < ActiveRecord::Base
  attr_accessible :code

  def self.codes_exist?
    self.count > 0
  end

  def self.has_code?(code)
    self.where(:code => code).count > 0
  end
end
