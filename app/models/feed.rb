class Feed < ActiveRecord::Base
  attr_accessible :title, :url, :feed_url, :last_fetched_at
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
      puts "Updated feed #{self.id}: #{self.title} (#{self.feed_url})"
    rescue => e
      puts "FAILED feed #{self.id}: #{self.title} (#{self.feed_url})"
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

  def self.update_next
    puts "Updating next block of feeds"

    start_time = Time.now

    num_total_feeds = Feed.num_feeds_with_at_least_one_group

    models = self.least_recently_fetched(num_total_feeds / 15)

    # first, update the last_fetched_at field so if this takes too long
    # the next run will just skip on to the next batch instead of repeating
    # this one
    models.each do |model|
      model.last_fetched_at = Time.now
      model.save
    end

    feeds = Feedzirra::Feed.fetch_and_parse(models.map{|m| m.feed_url})
    models.each do |model|
      if feeds.has_key?(model.feed_url)
        model.merge(feeds[model.feed_url])
        model.save
      end
    end

    finish_time = Time.now

    puts "Updated #{num_total_feeds/15} feeds in #{finish_time-start_time} seconds"
  end

  def self.num_feeds_with_at_least_one_group
    self.find_by_sql(["select count(distinct(feeds.id)) as num
      from feeds
      join feeds_groups on feeds_groups.feed_id=feeds.id"]).first.num
  end

  def self.least_recently_fetched(limit)
    self.find_by_sql(["select distinct feeds.*
      from feeds
      join feeds_groups on feeds_groups.feed_id=feeds.id
      order by last_fetched_at asc
      limit :limit", {:limit => limit}])
  end

  def self.by_user_id(user_id)
    self.find_by_sql(["select feeds.*, feed_names.name as custom_name
        from feeds
        join feeds_groups on feeds_groups.feed_id=feeds.id
        join groups on groups.id=feeds_groups.group_id and groups.user_id=:user_id
        left outer join feed_names on feed_names.feed_id=feeds.id and feed_names.user_id=:user_id
        order by groups.index_num asc, feeds.id asc", { :user_id => user_id }])
  end
end
