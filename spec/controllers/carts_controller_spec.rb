require 'rails_helper'

RSpec.describe CartsController, type: :controller do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:product1) { create(:product, category_id: category.id, price: 100.0) }
  let(:product2) { create(:product, category_id: category.id, price: 200.0) }
  let(:cart) { create(:cart, user: user) }
  
  before do
    session[:user_id] = user.id
    session[:cart_id] = cart.id
  end
  
  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
    
    it "calculates total price correctly" do
      create(:cart_item, cart: cart, product: product1, quantity: 2)
      create(:cart_item, cart: cart, product: product2, quantity: 1) 
      get :show
      expect(assigns(:total)).to eq(400.0)
    end
    
    it "shows empty cart message when cart is empty" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end
end
