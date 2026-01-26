require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
  
  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
    
    it "redirects if user is already logged in" do
      session[:user_id] = user.id
      get :new
      expect(response).to redirect_to(customer_dashboard_path)
    end
  end
  
  describe "POST #create" do
    context "with valid credentials" do
      it "logs in the user" do
        post :create, params: { email: user.email, password: 'password123' }
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(customer_dashboard_path)
      end
      
      it "redirects admin to admin dashboard" do
        admin = create(:user, :admin, email: 'admin@example.com', password: 'password123')
        post :create, params: { email: admin.email, password: 'password123' }
        expect(response).to redirect_to(admin_root_path)
      end
      
      it "shows success message" do
        post :create, params: { email: user.email, password: 'password123' }
        expect(flash[:notice]).to be_present
      end
    end
    
    context "with invalid credentials" do
      it "does not log in with wrong password" do
        post :create, params: { email: user.email, password: 'wrongpassword' }
        expect(session[:user_id]).to be_nil
        expect(response).to render_template(:new)
      end
      
      it "does not log in with wrong email" do
        post :create, params: { email: 'wrong@example.com', password: 'password123' }
        expect(session[:user_id]).to be_nil
        expect(response).to render_template(:new)
      end
      
      it "shows error message" do
        post :create, params: { email: user.email, password: 'wrongpassword' }
        expect(flash[:alert]).to be_present
      end
    end
    
    context "with missing fields" do
      it "requires email" do
        post :create, params: { password: 'password123' }
        expect(session[:user_id]).to be_nil
        expect(flash[:alert]).to include("Email is required")
      end
      
      it "requires password" do
        post :create, params: { email: user.email }
        expect(session[:user_id]).to be_nil
        expect(flash[:alert]).to include("Password is required")
      end
    end
  end
  
  describe "DELETE #destroy" do
    it "logs out the user" do
      session[:user_id] = user.id
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
    end
    
    it "shows success message" do
      session[:user_id] = user.id
      delete :destroy
      expect(flash[:notice]).to be_present
    end
  end
end
