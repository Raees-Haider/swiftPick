class AddShippingDetailsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :shipping_address, :text
    add_column :orders, :phone, :string
    add_column :orders, :payment_method, :string
  end
end
