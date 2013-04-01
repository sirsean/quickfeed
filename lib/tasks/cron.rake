namespace :cron do
  desc "This is performed every 1 minute."
  task :one => :environment do
    Feed.update_next
  end
end
