namespace :cron do
  desc "This is performed every 15 minutes."
  task :fifteen => :environment do
    Feed.update_all
  end
end
