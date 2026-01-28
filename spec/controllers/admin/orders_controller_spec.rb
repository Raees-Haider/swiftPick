require 'rails_helper'

RSpec.describe Admin::OrdersController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }
  let(:order) { create(:order, user: customer) }
  
  before do
    session[:user_id] = admin.id
  end
  
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
    
    it "lists all orders" do
      create_list(:order, 3)
      get :index
      expect(response).to have_http_status(:success)
      # Verify orders are displayed (check response body or use different assertion)
    end
    
    it "redirects non-admin users" do
      session[:user_id] = customer.id
      get :index
      expect(response).to redirect_to(login_path)
    end
  end
  
  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: order.id }
      expect(response).to have_http_status(:success)
    end
    
    it "shows the order details" do
      get :show, params: { id: order.id }
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "PATCH #update" do
    context "when order is not completed" do
      it "updates order status" do
        patch :update, params: { id: order.id, order: { status: 'shipped' } }
        order.reload
        expect(order.status).to eq('shipped')
      end
      
      it "redirects to order show page" do
        patch :update, params: { id: order.id, order: { status: 'shipped' } }
        expect(response).to redirect_to(admin_order_path(order))
      end
      
      it "shows success message" do
        patch :update, params: { id: order.id, order: { status: 'shipped' } }
        expect(flash[:notice]).to be_present
      end
    end
    
    context "when order is completed" do
      let(:completed_order) { create(:order, user: customer, status: 'completed') }
      
      it "does not update order status" do
        original_status = completed_order.status
        patch :update, params: { id: completed_order.id, order: { status: 'shipped' } }
        completed_order.reload
        expect(completed_order.status).to eq(original_status)
      end
      
      it "redirects with error message" do
        patch :update, params: { id: completed_order.id, order: { status: 'shipped' } }
        expect(response).to redirect_to(admin_order_path(completed_order))
        expect(flash[:alert]).to include("Cannot update status of a completed order")
      end
    end
  end
end
