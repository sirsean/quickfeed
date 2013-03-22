require "form"
require "rexml/Document"

class ImportController < ApplicationController
  before_filter :require_login

  def index
    @import_form = ImportForm.new
  end

  def upload
    opml = REXML::Document.new(File.read(params[:import_form][:opml].tempfile))
    feed_urls = []
    opml.elements["opml/body"].elements.each("outline") do |e|
      feed_urls << e.attributes["xmlUrl"]
      model = Feed.find_by_feed_url(e.attributes["xmlUrl"])
      if model.nil?
        model = Feed.new(
          :title => e.attributes["title"],
          :url => e.attributes["htmlUrl"],
          :feed_url => e.attributes["xmlUrl"],
        )
        model.save
      end

      group = Group.new(
        :user_id => current_user.id,
        :public => false,
        :name => model.title,
        :index_num => Group.next_index(current_user.id),
      )

      group.feeds << model

      group.save
    end

    redirect_to "/reader"
  end
end
