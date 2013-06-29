require "rexml/document"

module Opml
  class Parser
    def parse(xml)
      opml = REXML::Document.new(xml)

      groups = []

      if opml and opml.elements["opml/body"]
        opml.elements["opml/body"].elements.each("outline") do |e|
          group = Opml::Group.new(:title => e.attributes["title"])
          if e.elements["outline"]
            e.elements.each do |f|
              if f.name == "outline"
                feed = Opml::Feed.new(
                  :title => f.attributes["title"],
                  :url => f.attributes["htmlUrl"],
                  :feed_url => f.attributes["xmlUrl"],
                )
                group.feeds << feed
              end
            end
          else
            feed = Opml::Feed.new(
              :title => e.attributes["title"],
              :url => e.attributes["htmlUrl"],
              :feed_url => e.attributes["xmlUrl"],
            )
            group.feeds << feed
          end
          groups << group
        end
      end

      groups
    end
  end

  class Group
    attr_accessor :title, :feeds

    def initialize(opts)
      @title = opts[:title]
      @feeds = []
    end
  end

  class Feed
    attr_accessor :title, :url, :feed_url

    def initialize(opts)
      @title = opts[:title]
      @url = opts[:url]
      @feed_url = opts[:feed_url]
    end
  end
end
