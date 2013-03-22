xml.instruct!
xml.opml do
  xml.head do
    xml.title do
      xml.body "Subscriptions from Quickfeed"
    end
  end
  xml.body do
    @feeds.each do |feed|
      xml.outline(
        :text => feed.custom_name || feed.title,
        :title => feed.custom_name || feed.title,
        :type => "rss", 
        :xmlUrl => feed.feed_url, 
        :htmlUrl => feed.url
      )
    end
  end
end
