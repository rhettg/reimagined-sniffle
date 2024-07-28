# frozen_string_literal: true

class Note < ContentItem
  # Add any additional attributes or methods specific to Note here

  # Validation to ensure content is present
  validates :content, presence: true
end
