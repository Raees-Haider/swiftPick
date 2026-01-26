class AddNullConstraintsToProducts < ActiveRecord::Migration[8.1]
  def change
  change_column_null :products, :name, false
  change_column_null :products, :price, false
  change_column_null :products, :stock_quantity, false
end

end
