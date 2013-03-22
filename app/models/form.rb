require "table_free"

class FeedForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include TableFree

  attr_accessor :feed_name, :group_id, :group_name
end

class ImportForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include TableFree

  attr_accessor :opml
end

class MergeForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include TableFree

  attr_accessor :group_ids
end
