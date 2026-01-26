require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let(:category) { create(:category, name: "Electronics") }
  let(:category2) { create(:category, name: "Clothing") }
  let(:product1) { create(:product, name: "Laptop", category_id: category.id, active: true) }
  let(:product2) { create(:product, name: "Shirt", category_id: category2.id, active: true) }
  let(:inactive_product) { create(:product, name: "Inactive", category_id: category.id, active: false) }
  
  # Categories are already added by the factory, no need to add again
  
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
    
    it "shows only active products" do
      get :index
      expect(assigns(:products)).to include(product1, product2)
      expect(assigns(:products)).not_to include(inactive_product)
    end
    
    it "filters by category" do
      get :index, params: { category: "electronics" }
      expect(assigns(:products)).to include(product1)
      expect(assigns(:products)).not_to include(product2)
    end
    
    it "searches products by name" do
      get :index, params: { query: "laptop" }
      expect(assigns(:products)).to include(product1)
      expect(assigns(:products)).not_to include(product2)
    end
    
    it "searches products by description" do
      product1.update(description: "High performance laptop")
      get :index, params: { query: "performance" }
      expect(assigns(:products)).to include(product1)
    end
    
    it "searches products by category name" do
      get :index, params: { query: "electronics" }
      expect(assigns(:products)).to include(product1)
    end
    
    it "is case-insensitive" do
      get :index, params: { query: "LAPTOP" }
      expect(assigns(:products)).to include(product1)
    end
    
    it "returns no duplicates" do
      product1.categories << category2 unless product1.categories.include?(category2)
      get :index, params: { query: "laptop" }
      products = assigns(:products).to_a
      expect(products.count { |p| p.id == product1.id }).to eq(1)
    end
    
    it "handles empty search" do
      get :index, params: { query: "" }
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: product1.id }
      expect(response).to have_http_status(:success)
    end
    
    it "assigns the product" do
      get :show, params: { id: product1.id }
      expect(assigns(:product)).to eq(product1)
    end
    
    it "shows related products" do
      related = create(:product, category_id: category.id, active: true)
      # Category is already added by factory, no need to add again
      get :show, params: { id: product1.id }
      expect(assigns(:related_products)).to include(related)
    end
    
    it "redirects if product not found" do
      get :show, params: { id: 99999 }
      expect(response).to redirect_to(products_path)
      expect(flash[:alert]).to be_present
    end
  end
end
