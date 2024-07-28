# frozen_string_literal: true

class Image < ContentItem
  has_one_attached :file
  validates :file, presence: true
end
