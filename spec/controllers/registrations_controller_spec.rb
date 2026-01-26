require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
    
    it "redirects if user is already logged in" do
      user = create(:user)
      session[:user_id] = user.id
      get :new
      expect(response).to redirect_to(customer_dashboard_path)
    end
  end
  
  describe "POST #create" do
    context "with valid data" do
      let(:valid_params) do
        {
          user: {
            name: "John Doe",
            email: "john@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
      
      it "creates a new user" do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end
      
      it "logs in the user" do
        post :create, params: valid_params
        expect(session[:user_id]).to eq(User.last.id)
      end
      
      it "redirects to dashboard" do
        post :create, params: valid_params
        expect(response).to redirect_to(customer_dashboard_path)
      end
      
      it "creates user with customer role by default" do
        post :create, params: valid_params
        expect(User.last.role).to eq('customer')
      end
    end
    
    context "with invalid data" do
      it "does not create user with invalid email" do
        expect {
          post :create, params: {
            user: {
              name: "John Doe",
              email: "invalid-email",
              password: "password123",
              password_confirmation: "password123"
            }
          }
        }.not_to change(User, :count)
      end
      
      it "does not create user with short password" do
        expect {
          post :create, params: {
            user: {
              name: "John Doe",
              email: "john@example.com",
              password: "12345",
              password_confirmation: "12345"
            }
          }
        }.not_to change(User, :count)
      end
      
      it "does not create user with mismatched passwords" do
        expect {
          post :create, params: {
            user: {
              name: "John Doe",
              email: "john@example.com",
              password: "password123",
              password_confirmation: "password456"
            }
          }
        }.not_to change(User, :count)
      end
      
      it "does not create user with duplicate email" do
        create(:user, email: "existing@example.com")
        expect {
          post :create, params: {
            user: {
              name: "John Doe",
              email: "existing@example.com",
              password: "password123",
              password_confirmation: "password123"
            }
          }
        }.not_to change(User, :count)
      end
      
      it "renders new template on error" do
        post :create, params: {
          user: {
            name: "",
            email: "",
            password: "",
            password_confirmation: ""
          }
        }
        expect(response).to render_template(:new)
      end
    end
  end
end
 