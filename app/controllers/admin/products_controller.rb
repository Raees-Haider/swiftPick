class Admin::ProductsController < ApplicationController
  before_action :require_admin
  before_action :set_product, only: [:edit, :update, :destroy]

  

  def index
    @products = Product.all
  end

  def new
    @product = Product.new
  end

  def create
    permitted_params = product_params
    category_ids = permitted_params.delete(:category_ids) || []
    
    @product = Product.new(permitted_params)
    
    if category_ids.present? && category_ids.first.present?
      @product.category_id = category_ids.first.to_i
    end
    
    @product.category_ids = category_ids.map(&:to_i).reject(&:zero?) if category_ids.present?
    
    if @product.save
      redirect_to admin_products_path, notice: "Product created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    permitted_params = product_params
    category_ids = permitted_params.delete(:category_ids) || []
    
    @product.assign_attributes(permitted_params)
    
    if category_ids.present? && category_ids.first.present?
      @product.category_id = category_ids.first.to_i
    end
    
    @product.category_ids = category_ids.map(&:to_i).reject(&:zero?) if category_ids.present?
    
    if @product.save
      redirect_to admin_products_path, notice: "Product updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: "Product deleted successfully"
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    permitted = params.require(:product).permit(
      :name, :description, :price, :stock_quantity, :active, :image, category_ids: []
    )
    
    if permitted[:image].is_a?(String)
      permitted.delete(:image)
    end
    
    if permitted[:category_ids]
      permitted[:category_ids] = permitted[:category_ids].reject(&:blank?)
    end
    
    permitted
  end

end
