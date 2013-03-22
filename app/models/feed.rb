class Feed < ActiveRecord::Base
  attr_accessible :title, :url, :feed_url
  has_and_belongs_to_many :groups
  has_many :items

  def merge(feed)
    begin
      feed.entries.reverse.each do |entry|
        item = Item.find_by_feed_id_and_url(self.id, entry.url)
        if item.nil?
          item = Item.new(
            :title => entry.title,
            :url => entry.url,
            :author => entry.author,
            :summary => entry.summary,
            :content => entry.content,
            :published_at => entry.published || Time.now
          )
          self.items << item
        end
      end
    rescue => e
      puts e.message
      puts e.backtrace.join("\s")
    end
  end

  def self.update_all
    puts "Updating all feeds"
    models = self.all
    feeds = Feedzirra::Feed.fetch_and_parse(models.map{|m| m.feed_url})
    models.each do |model|
      puts model.inspect
      if feeds.has_key?(model.feed_url)
        model.merge(feeds[model.feed_url])
        model.save
      end
    end
    puts "Done updating all feeds"
  end

  def self.by_user_id(user_id)
    self.find_by_sql(["select feeds.*, feed_names.name as custom_name
        from feeds
        join feeds_groups on feeds_groups.feed_id=feeds.id
        join groups on groups.id=feeds_groups.group_id and groups.user_id=:user_id
        left outer join feed_names on feed_names.feed_id=feeds.id and feed_names.user_id=:user_id", { :user_id => user_id }])
  end
end
