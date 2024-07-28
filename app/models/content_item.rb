# Model for content items.
class ContentItem < ApplicationRecord
  has_many :content_item_tags
  has_many :tags, through: :content_item_tags
end
