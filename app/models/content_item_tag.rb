# Join model for content items and tags.
class ContentItemTag < ApplicationRecord
  belongs_to :content_item
  belongs_to :tag
end
