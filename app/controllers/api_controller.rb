class ApiController < ApplicationController
  respond_to :json

  def groups
    @groups = Group.by_user_id_with_unread(current_user.id)
    render :json => {
      :version => AppVersion.current.version,
      :groups => @groups,
    }
  end

  def items
    puts params.inspect
    group_id = params[:groupId]
    last_item_id = params[:lastItemId].to_i
    group = Group.find(group_id)
    @items = group.items(current_user.id, 40, last_item_id)
    render :json => {
      :num_items => group.num_items,
      :items => @items
    }
  end

  def read_item
    item_id = params[:itemId]
    ReadItem.transaction do
      if ReadItem.where(:item_id => item_id, :user_id => current_user.id).empty?
        ReadItem.create(:item_id => item_id, :user_id => current_user.id)
      end
    end
    render :json => { :item_id => item_id }
  end

  def mark_all_read
    group_id = params[:groupId]
    group = Group.find(group_id)
    ReadItem.transaction do
      group.unread_items(current_user.id).each do |item|
        ReadItem.create(:item_id => item.id, :user_id => current_user.id)
      end
    end
    render :json => { :group_id => group_id }
  end

  def add_feed
    feed_url = params[:feed][:feed_url]
    model = Feed.find_by_feed_url(feed_url)
    if model.nil?
      feed = Feedzirra::Feed.fetch_and_parse(feed_url)
      puts feed.inspect
      model = Feed.new(
        :title => feed.title,
        :url => feed.url,
        :feed_url => feed.feed_url
      )
      model.merge(feed)
      model.save
    end
    render :json => { :feed_id => model.id }
  end
end
