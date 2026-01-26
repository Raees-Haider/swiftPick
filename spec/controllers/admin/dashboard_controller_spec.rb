require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }
  
  describe "GET #index" do
    context "as admin" do
      before do
        session[:user_id] = admin.id
      end
      
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
      
      it "shows total sales" do
        create_list(:order, 3)
        get :index
        expect(assigns(:total_sales)).to eq(3)
      end
      
      it "shows total revenue" do
        create(:order, total_amount: 100.0)
        create(:order, total_amount: 200.0)
        get :index
        expect(assigns(:total_revenue)).to eq(300.0)
      end
      
      it "shows total customers" do
        create_list(:user, 5, :customer)
        get :index
        expect(assigns(:total_customers)).to eq(5)
      end
      
      it "shows total products" do
        category = create(:category)
        create_list(:product, 3, category_id: category.id, active: true)
        create(:product, category_id: category.id, active: false)
        get :index
        expect(assigns(:total_products)).to eq(3)
      end
    end
    
    context "as non-admin" do
      before do
        session[:user_id] = customer.id
      end
      
      it "redirects to login" do
        get :index
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end
    
    context "when not logged in" do
      it "redirects to login" do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
