class AppVersion2 < ActiveRecord::Migration
  def change
    version = AppVersion.current
    version.version = 2
    version.save
  end
end
