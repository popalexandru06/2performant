class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :title
      t.string :aff_code
      t.float :price
      t.float :old_price
      t.integer :campaign_id
      t.integer :widget_id
      t.string :short_message
      t.text :description
      t.integer :subcategory_id
      t.integer :source_id
      t.integer :brand_id
      t.boolean :is_active

      t.timestamps
    end
  end
end
