require "form"
require "opml"

class ImportController < ApplicationController
  before_filter :require_login

  def index
    @import_form = ImportForm.new
  end

  def upload
    parser = Opml::Parser.new
    groups = parser.parse(File.read(params[:import_form][:opml].tempfile))
    groups.each do |group|
      group_model = Group.new(
        :user_id => current_user.id,
        :public => false,
        :name => group.title,
        :index_num => Group.next_index(current_user.id),
      )

      group.feeds.each do |feed|
        feed_model = Feed.find_by_feed_url(feed.feed_url)
        if feed_model.nil?
          feed_model = Feed.new(
            :title => feed.title,
            :url => feed.url,
            :feed_url => feed.feed_url,
          )
        end
        group_model.feeds << feed_model
      end

      group_model.save
    end

    redirect_to "/reader"
  end
end
