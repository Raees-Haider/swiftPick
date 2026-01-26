class AddUniqueIndexToProductCategories < ActiveRecord::Migration[8.1]
  def change
    add_index :product_categories, [:product_id, :category_id], unique: true
  end
end
