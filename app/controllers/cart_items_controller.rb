class CartItemsController < ApplicationController
  def create
    @cart = current_cart
    @product = Product.find(params[:product_id])
    quantity = (params[:quantity] || 1).to_i
    
    # Check stock availability
    if @product.stock_quantity == 0
      redirect_back(fallback_location: product_path(@product), alert: "#{@product.name} is out of stock")
      return
    end
    
    # check quantity
    if quantity > @product.stock_quantity
      redirect_back(fallback_location: product_path(@product), alert: "Cannot add more. Only #{@product.stock_quantity} items available in stock.")
      return
    end
    
    # Find existing cart item or create new one
    @cart_item = @cart.cart_items.find_by(product_id: @product.id)
    
    if @cart_item
      new_quantity = @cart_item.quantity + quantity
      if new_quantity <= @product.stock_quantity
        @cart_item.update(quantity: new_quantity)
        redirect_back(fallback_location: product_path(@product), notice: "#{@product.name} added to cart")
      else
        redirect_back(fallback_location: product_path(@product), alert: "Cannot add more. Only #{@product.stock_quantity} items available in stock.")
      end
    else
      @cart_item = @cart.cart_items.create(
        product: @product,
        quantity: quantity
      )
      
      if @cart_item.persisted?
        redirect_back(fallback_location: product_path(@product), notice: "#{@product.name} added to cart")
      else
        redirect_back(fallback_location: product_path(@product), alert: "Failed to add product to cart")
      end
    end
  end

  def update
    @cart_item = CartItem.find(params[:id])
    action = params[:quantity_action]
    
    if action == "increase"
      new_quantity = @cart_item.quantity + 1
      if new_quantity <= @cart_item.product.stock_quantity
        @cart_item.update(quantity: new_quantity)
      else
        flash[:alert] = "Cannot add more. Only #{@cart_item.product.stock_quantity} items available in stock."
      end
    elsif action == "decrease" && @cart_item.quantity > 1
      @cart_item.update(quantity: @cart_item.quantity - 1)
    end
    
    redirect_to cart_path
  end

  def destroy
    @cart_item = CartItem.find(params[:id])
    @cart_item.destroy
    redirect_to cart_path, notice: "Item removed from cart"
  end
end
