class CreateContentItemTags < ActiveRecord::Migration[7.1]
  def change
    create_table :content_item_tags do |t|
      t.references :content_item, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
