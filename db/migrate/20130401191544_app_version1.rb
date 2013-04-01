class AppVersion1 < ActiveRecord::Migration
  def change
    version = AppVersion.current
    version.version = 1
    version.save
  end
end
