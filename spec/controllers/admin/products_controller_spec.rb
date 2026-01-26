require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }
  let(:category) { create(:category) }
  let(:product) { create(:product, category_id: category.id) }
  
  before do
    session[:user_id] = admin.id
  end
  
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
    
    it "lists all products" do
      product
      create_list(:product, 3, category_id: category.id)
      get :index
      expect(assigns(:products).count).to eq(4) 
    end
    
    it "redirects non-admin users" do
      session[:user_id] = customer.id
      get :index
      expect(response).to redirect_to(login_path)
    end
  end
  
  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
    
    it "assigns a new product" do
      get :new
      expect(assigns(:product)).to be_a_new(Product)
    end
  end
  
  describe "POST #create" do
    context "with valid data" do
      let(:valid_params) do
        {
          product: {
            name: "Test Product",
            description: "Test Description",
            price: 100.0,
            stock_quantity: 50,
            category_ids: [category.id],
            active: true,
            image: fixture_file_upload(Rails.root.join('spec/fixtures/files/test_image.jpg'), 'image/jpeg')
          }
        }
      end
      
      it "creates a new product" do
        expect {
          post :create, params: valid_params
        }.to change(Product, :count).by(1)
      end
      
      it "redirects to products index" do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_products_path)
      end
      
      it "assigns product to category" do
        post :create, params: valid_params
        product = Product.last
        expect(product).not_to be_nil
        expect(product.category_id).to eq(category.id)
        expect(product.categories).to include(category)
      end
    end
    
    context "with invalid data" do
      it "does not create product with missing name" do
        expect {
          post :create, params: {
            product: {
              description: "Test",
              price: 100.0,
              stock_quantity: 50,
              category_id: category.id
            }
          }
        }.not_to change(Product, :count)
      end
      
      it "does not create product with negative price" do
        expect {
          post :create, params: {
            product: {
              name: "Test",
              price: -10,
              stock_quantity: 50,
              category_id: category.id
            }
          }
        }.not_to change(Product, :count)
      end
      
      it "does not create product with missing category" do
        expect {
          post :create, params: {
            product: {
              name: "Test",
              price: 100.0,
              stock_quantity: 50
            }
          }
        }.not_to change(Product, :count)
      end
      
      it "renders new template on error" do
        post :create, params: {
          product: {
            name: "",
            price: nil,
            stock_quantity: nil
          }
        }
        expect(response).to render_template(:new)
      end
    end
  end
  
  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: product.id }
      expect(response).to have_http_status(:success)
    end
    
    it "assigns the product" do
      get :edit, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
    end
  end
  
  describe "PATCH #update" do
    context "with valid data" do
      it "updates product name" do
        patch :update, params: {
          id: product.id,
          product: { name: "Updated Name" }
        }
        product.reload
        expect(product.name).to eq("Updated Name")
      end
      
      it "updates product price" do
        patch :update, params: {
          id: product.id,
          product: { price: 200.0 }
        }
        product.reload
        expect(product.price).to eq(200.0)
      end
      
      it "updates product stock" do
        patch :update, params: {
          id: product.id,
          product: { stock_quantity: 100 }
        }
        product.reload
        expect(product.stock_quantity).to eq(100)
      end
      
      it "redirects to products index" do
        patch :update, params: {
          id: product.id,
          product: { name: "Updated" }
        }
        expect(response).to redirect_to(admin_products_path)
      end
    end
    
    context "with invalid data" do
      it "does not update with empty name" do
        original_name = product.name
        patch :update, params: {
          id: product.id,
          product: { name: "" }
        }
        product.reload
        expect(product.name).to eq(original_name)
      end
      
      it "renders edit template on error" do
        patch :update, params: {
          id: product.id,
          product: { name: "" }
        }
        expect(response).to render_template(:edit)
      end
    end
  end
  
  describe "DELETE #destroy" do
    it "deletes the product" do
      product_to_delete = create(:product, category_id: category.id)
      expect {
        delete :destroy, params: { id: product_to_delete.id }
      }.to change(Product, :count).by(-1)
    end
    
    it "redirects to products index" do
      delete :destroy, params: { id: product.id }
      expect(response).to redirect_to(admin_products_path)
    end
  end
end
