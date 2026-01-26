require 'rails_helper'

RSpec.describe CartItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:product) { create(:product, category_id: category.id, stock_quantity: 10, price: 100.0) }
  let(:cart) { create(:cart, user: user) }
  
  before do
    session[:user_id] = user.id
    session[:cart_id] = cart.id
  end
  
  describe "POST #create" do
    context "with valid product" do
      it "adds product to cart" do
        expect {
          post :create, params: { product_id: product.id, quantity: 2 }
        }.to change(CartItem, :count).by(1)
      end
      
      it "updates cart correctly" do
        post :create, params: { product_id: product.id, quantity: 2 }
        cart_item = cart.cart_items.find_by(product_id: product.id)
        expect(cart_item.quantity).to eq(2)
      end
      
      it "increments quantity if product already in cart" do
        create(:cart_item, cart: cart, product: product, quantity: 2)
        post :create, params: { product_id: product.id, quantity: 3 }
        cart_item = cart.cart_items.find_by(product_id: product.id)
        expect(cart_item.quantity).to eq(5)
      end
      
      it "shows success message" do
        post :create, params: { product_id: product.id, quantity: 1 }
        expect(flash[:notice]).to be_present
      end
    end
    
    context "with invalid data" do
      it "does not add out of stock product" do
        product.update(stock_quantity: 0)
        expect {
          post :create, params: { product_id: product.id, quantity: 1 }
        }.not_to change(CartItem, :count)
        expect(flash[:alert]).to be_present
      end
      
      it "does not add more than available stock" do
        expect {
          post :create, params: { product_id: product.id, quantity: 15 }
        }.not_to change(CartItem, :count)
        expect(flash[:alert]).to be_present
      end
      
      it "does not exceed stock when incrementing" do
        create(:cart_item, cart: cart, product: product, quantity: 8)
        post :create, params: { product_id: product.id, quantity: 5 }
        cart_item = cart.cart_items.find_by(product_id: product.id)
        expect(cart_item.quantity).to eq(8) # Should not increase
        expect(flash[:alert]).to be_present
      end
    end
  end
  
  describe "PATCH #update" do
    let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }
    
    it "increases quantity" do
      patch :update, params: { id: cart_item.id, quantity_action: "increase" }
      cart_item.reload
      expect(cart_item.quantity).to eq(3)
    end
    
    it "decreases quantity" do
      patch :update, params: { id: cart_item.id, quantity_action: "decrease" }
      cart_item.reload
      expect(cart_item.quantity).to eq(1)
    end
    
    it "does not decrease below 1" do
      cart_item.update(quantity: 1)
      patch :update, params: { id: cart_item.id, quantity_action: "decrease" }
      cart_item.reload
      expect(cart_item.quantity).to eq(1)
    end
    
    it "does not increase beyond stock" do
      cart_item.update(quantity: 10)
      patch :update, params: { id: cart_item.id, quantity_action: "increase" }
      cart_item.reload
      expect(cart_item.quantity).to eq(10)
      expect(flash[:alert]).to be_present
    end
  end
  
  describe "DELETE #destroy" do
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }
    
    it "removes product from cart" do
      expect {
        delete :destroy, params: { id: cart_item.id }
      }.to change(CartItem, :count).by(-1)
    end
    
    it "updates cart correctly" do
      delete :destroy, params: { id: cart_item.id }
      expect(cart.cart_items.count).to eq(0)
    end
    
    it "shows success message" do
      delete :destroy, params: { id: cart_item.id }
      expect(flash[:notice]).to be_present
    end
  end
end
