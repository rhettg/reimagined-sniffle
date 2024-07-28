# frozen_string_literal: true

class ContentItem < ApplicationRecord
  has_many :content_item_tags
  has_many :tags, through: :content_item_tags

  self.inheritance_column = :type

  # Ensure that subclasses are correctly set up for STI
  def self.types
    %w[Image Link Note]
  end
end
