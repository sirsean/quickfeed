require "form"

class SubscribeController < ApplicationController
  before_filter :require_login

  def index
    @feed = Feed.new
  end

  def complete
    @feed_id = params[:feed_id]

    @feed = Feed.find(@feed_id)

    feed_name = FeedName.where(:user_id => current_user.id, :feed_id => @feed_id).first

    @groups = Group.where(:user_id => current_user.id)
    @select_groups = [["New Group", -1]] + @groups.map { |g| [g.name, g.id] }

    @feed_form = FeedForm.new(
      :feed_name => feed_name.nil? ? @feed.title : feed_name.name,
      :group_id => -1,
      :group_name => @feed.title
    )

    if request.post?
      data = params[:feed_form]

      if data[:group_id].to_i == -1
        group = Group.new(
          :user_id => current_user.id,
          :public => false,
          :name => data[:group_name],
          :index_num => Group.next_index(current_user.id),
        )
      else
        group = Group.find(data[:group_id].to_i)
      end

      if feed_name.nil?
        feed_name = FeedName.new(
          :user_id => current_user.id,
          :feed_id => @feed_id,
          :name => data[:feed_name]
        )
      else
        feed_name.name = data[:feed_name]
      end

      group.feeds << @feed

      group.save
      feed_name.save
      redirect_to "/reader"
    end
  end
end
