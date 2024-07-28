# frozen_string_literal: true

class ContentItemTag < ApplicationRecord
  belongs_to :content_item
  belongs_to :tag
end
