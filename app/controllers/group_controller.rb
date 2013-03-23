require "form"

class GroupController < ApplicationController
  before_filter :require_login

  def index
    @groups = Group.where(:user_id => current_user.id).order("index_num asc")
  end

  def new
    if request.post?
      data = params[:group]

      @group = Group.new(
        :user_id => current_user.id,
        :name => data[:name],
        :public => false,
        :index_num => Group.next_index(current_user.id),
      )

      if @group.save
        flash.notice = "Group created"
        redirect_to "/group"
      end
    else
      @group = Group.new
    end
  end

  def show
    group_id = params[:group_id]
    @group = Group.find(group_id) || not_found

    if @group.user_id != current_user.id
      not_found
    end

    @feed_names = {}
    @group.feeds.each do |feed|
      @feed_names[feed.id] = feed.title
    end
    FeedName.where(:user_id => current_user.id, :feed_id => @group.feeds.map{|f| f.id}).each do |feed_name|
      @feed_names[feed_name.feed_id] = feed_name.name
    end
  end

  def edit
    group_id = params[:group_id]

    @group = Group.find(group_id) || not_found
    not_found unless @group.user_id == current_user.id

    if request.post?
      data = params[:group]

      @group.name = data[:name]

      if @group.save
        flash.notice = "Group updated"
        redirect_to "/group/show/#{@group.id}"
      end
    end
  end

  def delete
    group_id = params[:group_id]

    group = Group.find(group_id) || not_found
    not_found unless group.user_id == current_user.id

    group.delete

    Group.reindex(current_user.id)

    flash.notice = "Group deleted"
    redirect_to "/group"
  end

  def remove_feed
    group_id = params[:group_id]
    feed_id = params[:feed_id]

    group = Group.find(group_id) || not_found
    feed = Feed.find(feed_id) || not_found
    not_found unless group.user_id == current_user.id

    group.feeds.delete(feed)

    group.save

    flash.notice = "Feed removed"
    redirect_to "/group/show/#{group_id}"
  end

  def order
    group_id = params[:group_id]
    direction = params[:direction].downcase.to_sym

    groups = Group.where(:user_id => current_user.id).order("index_num asc")
    group = groups.select{|x| x.id == group_id.to_i}.first

    if :top == direction
      Group.transaction do
        groups.select{|x| (0...group.index_num).include?(x.index_num)}.each do |to_move|
          to_move.index_num += 1
          to_move.save
        end
        group.index_num = 0
        group.save
      end
    elsif :up == direction
      if group.index_num > 0
        above = groups.select{|x| x.index_num == group.index_num-1}.first
        above.index_num += 1
        group.index_num -= 1
        Group.transaction do
          above.save
          group.save
        end
      end
    elsif :down == direction
      if group.index_num < groups.size - 1
        below = groups.select{|x| x.index_num == group.index_num+1}.first
        below.index_num -= 1
        group.index_num += 1
        Group.transaction do
          below.save
          group.save
        end
      end
    end

    redirect_to "/group##{group_id}"
  end

  def merge
    group_id = params[:group_id]

    @group = Group.find(group_id) || not_found
    not_found unless @group.user_id == current_user.id

    @merge = MergeForm.new

    @groups = Group.where(:user_id => current_user.id).order("index_num asc")
    @select_groups = @groups.select{|g| g.id != @group.id }.map { |g| [g.name, g.id] }

    if request.post?
      params[:merge_form][:group_ids].each do |merge_id|
        begin
          group_to_merge = Group.find(merge_id.to_i)
        rescue
          # if it's not found this dies?
          # and the <select> always gives us a "" which won't be found
        end
        if not group_to_merge.nil?
          @group.feeds += group_to_merge.feeds
          @group.feeds.uniq!
          group_to_merge.feeds = []
          group_to_merge.save
          group_to_merge.delete
        end
      end

      @group.save

      flash.notice = "Merged!"
      redirect_to "/group/show/#{@group.id}"
    end
  end
end
