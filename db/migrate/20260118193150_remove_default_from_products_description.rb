class RemoveDefaultFromProductsDescription < ActiveRecord::Migration[8.1]
  def change
    change_column_default :products, :description, from: "t", to: nil
  end
end
