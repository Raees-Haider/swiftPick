class CartsController < ApplicationController
  def show
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(:product) if @cart.persisted?
    @cart_items ||= []
    @total = @cart_items.sum { |item| item.product.price * item.quantity }
  end
end
