class CustomersController < ApplicationController
  before_action :require_login, only: [:show_profile, :edit_profile, :update_profile, :orders]
  
  def dashboard
    @user = current_user
    @orders = @user ? @user.orders.includes(:order_items).order(created_at: :desc) : []
    @gaming_products = Product.joins(:categories)
                               .where("LOWER(categories.name) LIKE ?", "%gaming%")
                               .where(active: true)
                               .includes(image_attachment: :blob)
                               .distinct
                               .limit(5)
    @books_products = Product.joins(:categories)
                               .where("LOWER(categories.name) LIKE ?", "%books%")
                               .where(active: true)
                               .includes(image_attachment: :blob)
                               .distinct
                               .limit(6)
  end
  
  def show_profile
    @user = current_user
    @orders = @user.orders.includes(order_items: :product).order(created_at: :desc)
  end
  
  def edit_profile
    @user = current_user
  end
  
  def update_profile
    @user = current_user
    
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully"
    else
      render :edit_profile, status: :unprocessable_entity
    end
  end
  
  def orders
    @user = current_user
    @orders = @user.orders.includes(order_items: :product).order(created_at: :desc)
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
