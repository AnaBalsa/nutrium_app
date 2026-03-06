class CreateServices < ActiveRecord::Migration[7.2]
  def change
    create_table :services do |t|
      t.references :nutritionist, null: false, foreign_key: true
      t.string :name
      t.integer :price
      t.string :currency
      t.integer :duration_minutes
      t.string :location_name
      t.float :location_lat
      t.float :location_lng

      t.timestamps
    end
  end
end
