class ExportController < ApplicationController
  before_filter :require_login

  def index
  end

  def subscriptions
    @feeds = Feed.by_user_id(current_user.id)
    respond_to do |format|
      format.xml
    end
  end
end
