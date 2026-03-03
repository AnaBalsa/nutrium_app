class CreateNutritionists < ActiveRecord::Migration[7.2]
  def change
    create_table :nutritionists do |t|
      t.string :name

      t.timestamps
    end
  end
end
