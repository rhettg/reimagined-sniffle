# Model for content items.
class ContentItem < ApplicationRecord
  has_many :content_item_tags, dependent: :destroy
  has_many :tags, through: :content_item_tags
  has_one_attached :file
end
