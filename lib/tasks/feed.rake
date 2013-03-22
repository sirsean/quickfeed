namespace :feed do
  desc "Fetch and merge a feed into the database."
  task :fetch, [:url] => [:environment] do |t, args|
    url = args[:url]
    if url.nil?
      puts "Must enter a feed URL"
    else
      puts "Fetching feed: #{url}"
      feed = Feedzirra::Feed.fetch_and_parse(url)
      model = Feed.find_by_feed_url(url)
      if model.nil?
        model = Feed.new(
          :title => feed.title,
          :url => feed.url,
          :feed_url => feed.feed_url
        )
      end

      puts model.inspect

      model.merge(feed)

      model.save
    end
  end

  desc "Update all feeds and merge their entries."
  task :update_all => :environment do
    Feed.update_all
  end
end
