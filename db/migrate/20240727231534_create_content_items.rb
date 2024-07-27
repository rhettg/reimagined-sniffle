class CreateContentItems < ActiveRecord::Migration[7.1]
  def change
    create_table :content_items do |t|
      t.string :type

      t.timestamps
    end
  end
end
