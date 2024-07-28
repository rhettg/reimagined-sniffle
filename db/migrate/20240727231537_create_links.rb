# frozen_string_literal: true

class CreateLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :links do |t|
      t.string :url
      t.string :title
      t.text :description
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
