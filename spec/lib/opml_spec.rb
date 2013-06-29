require "spec_helper"
require "opml"

describe Opml do
  it "when there's no XML" do
    parser = Opml::Parser.new
    groups = parser.parse("")
    groups.empty?.should == true
  end

  it "when there are feeds but no groups" do
    parser = Opml::Parser.new
    groups = parser.parse(File.read("#{Rails.root}/spec/fixtures/subscriptions_sean.xml"))
    groups.size.should == 94

    g0 = groups[0]
    g0.title.should == "Seth's Blog"
    g0.feeds.size.should == 1
    g0.feeds[0].title.should == "Seth's Blog"
    g0.feeds[0].url.should == "http://sethgodin.typepad.com/seths_blog/"
    g0.feeds[0].feed_url.should == "http://feeds.feedburner.com/typepad/sethsmainblog"
  end

  it "when there are groups with multiple feeds in them" do
    parser = Opml::Parser.new
    groups = parser.parse(File.read("#{Rails.root}/spec/fixtures/subscriptions_robert.xml"))
    groups.size.should == 8

    groups[0].title.should == "Google Alerts - B. Todd Jones"
    groups[0].feeds.size.should == 1
    groups[0].feeds[0].title.should == "Google Alerts - B. Todd Jones"
    groups[0].feeds[0].url.should == "http://www.google.com/reader/view/user%2F13722468355078230769%2Fstate%2Fcom.google%2Falerts%2F5236086357890866165"
    groups[0].feeds[0].feed_url.should == "http://www.google.com/reader/public/atom/user/13722468355078230769/state/com.google/alerts/5236086357890866165"

    groups[1].title.should == "Baseball Blogs"
    groups[1].feeds.size.should == 7
    groups[1].feeds[0].title.should == "All Rob Neyer Posts"
    groups[1].feeds[0].url = "http://www.sbnation.com/"
    groups[1].feeds[0].feed_url = "http://www.sbnation.com/authors/rob-neyer/rss"
  end
end
