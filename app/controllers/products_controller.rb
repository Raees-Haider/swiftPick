class ProductsController < ApplicationController
  def index
    @products = active_products
    @products = filter_by_category(@products) if params[:category].present?
    @products = search_products(@products) if params[:query].present?
  end

  def show
    @product = Product.find(params[:id])
    @related_products = find_related_products(@product)
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "Product not found"
  end

  private

  def active_products
    Product.where(active: true).includes(:categories)
  end

  def filter_by_category(products)
    category_name = params[:category].downcase
    products.joins(:categories)
            .where("LOWER(categories.name) LIKE ?", "%#{category_name}%")
            .distinct
  end

  def search_products(products)
    search_term = "%#{params[:query].downcase}%"
    products.left_joins(:categories)
            .where(
              "LOWER(products.name) LIKE ? OR LOWER(products.description) LIKE ? OR LOWER(categories.name) LIKE ?",
              search_term, search_term, search_term
            )
            .distinct
  end

  def find_related_products(product)
    category_ids = product.categories.select(:id)
    
    Product.where(active: true)
           .where.not(id: product.id)
           .joins(:categories)
           .where(categories: { id: category_ids })
           .distinct
           .limit(4)
  end
end
