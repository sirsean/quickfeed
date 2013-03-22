class Group < ActiveRecord::Base
  attr_accessible :name, :public, :user_id, :index_num
  has_and_belongs_to_many :feeds
  belongs_to :user

  def items(user_id)
    Group.find_by_sql(["select items.*, (select read_items.item_id is null) as unread, feeds.title as feed_title, feed_names.name as feed_name
      from items
      join feeds_groups on feeds_groups.feed_id=items.feed_id
      join groups on feeds_groups.group_id=groups.id
      left outer join read_items on items.id=read_items.item_id and read_items.user_id=:user_id
      join feeds on feeds.id=items.feed_id
      left outer join feed_names on feed_names.feed_id=items.feed_id and feed_names.user_id=:user_id
      where groups.id=:group_id
      order by items.published_at desc, items.id desc", { :user_id => user_id, :group_id => self.id }])
  end

  def self.by_user_id_with_unread(user_id)
    Group.find_by_sql(["select groups.*, sum((select read_items.item_id is null and items.id is not null)) as unread
      from groups
      join feeds_groups on feeds_groups.group_id=groups.id
      left outer join items on items.feed_id=feeds_groups.feed_id
      left outer join read_items on items.id=read_items.item_id and read_items.user_id=:user_id
      where groups.user_id=:user_id
      group by groups.id
      order by groups.index_num asc", { :user_id => user_id }])
  end

  def self.max_index(user_id)
    Group.where(:user_id => user_id).maximum(:index_num)
  end

  def self.next_index(user_id)
    max = self.max_index(user_id)
    if max.nil?
      0
    else
      max + 1
    end
  end
end
