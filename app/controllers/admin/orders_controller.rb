class Admin::OrdersController < ApplicationController
  before_action :require_admin
  before_action :set_order, only: [:show, :update]
  
  def index
    @orders = Order.includes(:user, order_items: :product).order(created_at: :desc)
  end
  
  def show
    @order = Order.includes(:user, order_items: :product).find(params[:id])
  end
  
  def update
    if @order.completed?
      redirect_to admin_order_path(@order), alert: "Cannot update status of a completed order"
      return
    end
    
    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: "Order status updated successfully"
    else
      render :show, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_order
    @order = Order.find(params[:id])
  end
  
  def order_params
    params.require(:order).permit(:status)
  end
end
