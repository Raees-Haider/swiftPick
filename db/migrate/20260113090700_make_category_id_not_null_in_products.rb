class MakeCategoryIdNotNullInProducts < ActiveRecord::Migration[8.1]
  def up
    
    change_column_null :products, :category_id, false
  end

  def down
    
    change_column_null :products, :category_id, true
  end
end
