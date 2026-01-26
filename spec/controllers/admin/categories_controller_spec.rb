require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }
  let(:category) { create(:category) }
  
  before do
    session[:user_id] = admin.id
  end
  
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
    
    it "lists all categories" do
      create_list(:category, 3)
      get :index
      expect(assigns(:categories).count).to eq(3)
    end
    
    it "redirects non-admin users" do
      session[:user_id] = customer.id
      get :index
      expect(response).to redirect_to(login_path)
    end
  end
  
  describe "POST #create" do
    context "with valid data" do
      it "creates a new category" do
        expect {
          post :create, params: { category: { name: "New Category" } }
        }.to change(Category, :count).by(1)
      end
      
      it "redirects to categories index" do
        post :create, params: { category: { name: "New Category" } }
        expect(response).to redirect_to(admin_categories_path)
      end
    end
    
    context "with invalid data" do
      it "does not create category with duplicate name" do
        create(:category, name: "Existing")
        expect {
          post :create, params: { category: { name: "Existing" } }
        }.not_to change(Category, :count)
      end
      
      it "does not create category with empty name" do
        expect {
          post :create, params: { category: { name: "" } }
        }.not_to change(Category, :count)
      end
    end
  end
   
  describe "PATCH #update" do
    it "updates category name" do
      patch :update, params: { id: category.id, category: { name: "Updated Name" } }
      category.reload
      expect(category.name).to eq("Updated Name")
    end
  end
  
  describe "DELETE #destroy" do
    it "deletes the category" do
      category_to_delete = create(:category)
      expect {
        delete :destroy, params: { id: category_to_delete.id }
      }.to change(Category, :count).by(-1)
    end
  end
end
