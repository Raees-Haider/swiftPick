require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }
  
  before do
    session[:user_id] = admin.id
  end
  
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
    
    it "lists all users" do
      create_list(:user, 3)
      get :index
      expect(assigns(:users).count).to be >= 3
    end
    
    it "redirects non-admin users" do
      session[:user_id] = customer.id
      get :index
      expect(response).to redirect_to(login_path)
    end
  end
  
  describe "DELETE #destroy" do
    it "deletes a customer user" do
      user_to_delete = create(:user, :customer)
      expect {
        delete :destroy, params: { id: user_to_delete.id }
      }.to change(User, :count).by(-1)
    end
    
    it "cannot delete admin users" do
      admin_to_delete = create(:user, :admin)
      expect {
        delete :destroy, params: { id: admin_to_delete.id }
      }.not_to change(User, :count)
      expect(flash[:alert]).to include("Cannot delete an admin user")
    end
    
    it "redirects to users index" do
      user_to_delete = create(:user, :customer)
      delete :destroy, params: { id: user_to_delete.id }
      expect(response).to redirect_to(admin_users_path)
    end
    
    it "shows success message" do
      user_to_delete = create(:user, :customer)
      delete :destroy, params: { id: user_to_delete.id }
      expect(flash[:notice]).to be_present
    end
    
    it "handles non-existent user" do
      delete :destroy, params: { id: 99999 }
      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to be_present
    end
  end
end
