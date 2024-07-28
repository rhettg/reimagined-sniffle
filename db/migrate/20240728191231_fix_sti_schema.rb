class FixStiSchema < ActiveRecord::Migration[7.1]
  def change
    # Remove unnecessary tables
    drop_table :images
    drop_table :links
    drop_table :notes

    # Add necessary columns to content_items table for STI
    change_table :content_items do |t|
      t.string :title
      t.string :url
      t.text :content
      t.references :file, polymorphic: true, index: true
    end
  end
end
