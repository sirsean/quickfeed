class AppVersion < ActiveRecord::Base
  attr_accessible :version

  def self.current
    version = self.first
    if version.nil?
      version = AppVersion.new(:version => 0)
    end
    version
  end
end
