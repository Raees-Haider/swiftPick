require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include Rails.application.routes.url_helpers
  
  controller do
    def test_action
      render plain: "test"
    end
  end
  
  before do
    routes.draw { get "test_action" => "anonymous#test_action" }
  end
  
  describe "require_login" do
    it "allows logged in users" do
      user = create(:user)
      session[:user_id] = user.id
      get :test_action
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "require_admin" do
    controller do
      before_action :require_admin
      
      def admin_action
        render plain: "admin"
      end
    end
    
    before do
      routes.draw { get "admin_action" => "anonymous#admin_action" }
    end
    
    it "allows admin users" do
      admin = create(:user, :admin)
      session[:user_id] = admin.id
      get :admin_action
      expect(response).to have_http_status(:success)
    end
    
    it "redirects non-admin users" do
      user = create(:user, :customer)
      session[:user_id] = user.id
      get :admin_action
      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eq("Access denied")
    end
    
    it "redirects non-logged-in users" do
      get :admin_action
      expect(response).to redirect_to(login_path)
    end
  end
end
