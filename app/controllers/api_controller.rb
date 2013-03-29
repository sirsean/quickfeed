class ApiController < ApplicationController
  respond_to :json

  def groups
    @groups = Group.by_user_id_with_unread(current_user.id)
    respond_with @groups
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

  def read_items
    item_ids = params[:itemIds]
    if item_ids
      ReadItem.transaction do
        item_ids.each do |item_id|
          if ReadItem.where(:item_id => item_id, :user_id => current_user.id).empty?
            ReadItem.create(:item_id => item_id, :user_id => current_user.id)
          end
        end
      end
    end
    render :json => { :item_ids => item_ids }
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
