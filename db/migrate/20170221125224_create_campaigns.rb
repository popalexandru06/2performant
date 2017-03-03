class CreateCampaigns < ActiveRecord::Migration[5.0]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :url
      t.integer :source_id

      t.timestamps
    end
  end
end
