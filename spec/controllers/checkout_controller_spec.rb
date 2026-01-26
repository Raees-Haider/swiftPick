require 'rails_helper'

RSpec.describe CheckoutController, type: :controller do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:product) { create(:product, category_id: category.id) }
  let(:cart) { create(:cart, user: user) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }
  
  before do
    session[:user_id] = user.id
    session[:cart_id] = cart.id
  end
  
  describe "GET #new" do
    context "when user is logged in" do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
      
      it "sets default step to address" do
        get :new
        expect(assigns(:step)).to eq('address')
      end
      
      it "loads session data" do
        session[:checkout_address] = "123 Test St"
        session[:checkout_phone] = "1234567890"
        session[:checkout_payment_method] = "credit_card"
        
        get :new
        expect(assigns(:shipping_address)).to eq("123 Test St")
        expect(assigns(:phone)).to eq("1234567890")
        expect(assigns(:payment_method)).to eq("credit_card")
      end
    end
    
    context "when user is not logged in" do
      before { session[:user_id] = nil }
      
      it "redirects to login" do
        get :new
        expect(response).to redirect_to(login_path)
      end
    end
  end
  
  describe "PATCH #update_step" do
    context "with address step" do
      it "saves address and phone to session" do
        patch :update_step, params: {
          step: 'address',
          shipping_address: '123 Test Street',
          phone: '1234567890'
        }
        
        expect(session[:checkout_address]).to eq('123 Test Street')
        expect(session[:checkout_phone]).to eq('1234567890')
        expect(response).to redirect_to(checkout_path(step: 'payment'))
      end
      
      it "redirects back if fields are blank" do
        patch :update_step, params: {
          step: 'address',
          shipping_address: '',
          phone: ''
        }
        
        expect(response).to redirect_to(checkout_path(step: 'address'))
        expect(flash[:alert]).to be_present
      end
    end
    
    context "with payment step" do
      before do
        session[:checkout_address] = '123 Test Street'
        session[:checkout_phone] = '1234567890'
      end
      
      it "saves payment method to session" do
        patch :update_step, params: {
          step: 'payment',
          payment_method: 'cash_on_delivery'
        }
        
        expect(session[:checkout_payment_method]).to eq('cash_on_delivery')
        expect(response).to redirect_to(checkout_path(step: 'review'))
      end
      
      it "redirects back if payment method is blank" do
        patch :update_step, params: {
          step: 'payment',
          payment_method: ''
        }
        
        expect(response).to redirect_to(checkout_path(step: 'payment'))
        expect(flash[:alert]).to be_present
      end
    end
  end
  
  describe "GET #payment" do
    before do
      session[:checkout_payment_method] = 'credit_card'
    end
    
    it "returns http success" do
      get :payment
      expect(response).to have_http_status(:success)
    end
    
    it "redirects if payment method is not credit_card" do
      session[:checkout_payment_method] = 'cash_on_delivery'
      get :payment
      expect(response).to redirect_to(checkout_path(step: 'review'))
    end
  end
  
  describe "POST #create_payment_intent" do
    before do
      session[:checkout_payment_method] = 'credit_card'
    end
    
    it "creates a payment intent with Stripe" do
      payment_intent = mock_stripe_payment_intent_create(amount: 11950)
      
      post :create_payment_intent
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['clientSecret']).to be_present
    end
    
    it "calculates correct total amount" do
      # Calculate expected amount: (product price * quantity) * (1 + tax) + shipping, all in cents
      subtotal = product.price * 2 # 2 items
      tax = subtotal * 0.18 # 18% tax
      shipping = 150.0
      expected_total_cents = ((subtotal + tax + shipping) * 100).to_i
      
      payment_intent = mock_stripe_payment_intent_create(amount: expected_total_cents)
      
      post :create_payment_intent
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['clientSecret']).to be_present
      # Verify the payment intent was created with correct amount
      expect(Stripe::PaymentIntent).to have_received(:create).with(
        hash_including(amount: expected_total_cents)
      )
    end
    
    it "handles Stripe errors" do
      mock_stripe_error
      
      post :create_payment_intent
      
      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to be_present
    end
  end
  
  describe "POST #complete_payment" do
    let(:payment_intent_id) { "pi_test_1234567890" }
    
    before do
      session[:checkout_payment_method] = 'credit_card'
      session[:checkout_address] = '123 Test Street'
      session[:checkout_phone] = '1234567890'
    end
    
    it "creates order after successful payment" do
      payment_intent = mock_stripe_payment_intent_retrieve(
        payment_intent_id: payment_intent_id,
        status: 'succeeded'
      )
      
      expect {
        post :complete_payment, params: { payment_intent_id: payment_intent_id }
      }.to change(Order, :count).by(1)
      
      order = Order.last
      expect(order.status).to eq('pending')
      expect(order.stripe_payment_intent_id).to eq(payment_intent_id)
      expect(order.payment_method).to eq('credit_card')
    end
    
    it "redirects if payment was not successful" do
      payment_intent = mock_stripe_payment_intent_retrieve(
        payment_intent_id: payment_intent_id,
        status: 'requires_payment_method'
      )
      
      post :complete_payment, params: { payment_intent_id: payment_intent_id }
      
      expect(response).to redirect_to(checkout_payment_path)
      expect(flash[:alert]).to be_present
    end
    
    it "handles missing payment intent id" do
      post :complete_payment, params: { payment_intent_id: '' }
      
      expect(response).to redirect_to(checkout_payment_path)
      expect(flash[:alert]).to be_present
    end
  end
  
  describe "POST #create" do
    before do
      session[:checkout_address] = '123 Test Street'
      session[:checkout_phone] = '1234567890'
      session[:checkout_payment_method] = 'cash_on_delivery'
    end
    
    it "creates an order" do
      expect {
        post :create
      }.to change(Order, :count).by(1)
    end
    
    it "creates order items" do
      expect {
        post :create
      }.to change(OrderItem, :count).by(1)
    end
    
    it "updates product stock" do
      initial_stock = product.stock_quantity
      post :create
      product.reload
      expect(product.stock_quantity).to eq(initial_stock - cart_item.quantity)
    end
    
    it "clears the cart" do
      post :create
      cart.reload
      expect(cart.cart_items.count).to eq(0)
    end
    
    it "redirects to dashboard on success" do
      post :create
      expect(response).to redirect_to(customer_dashboard_path)
      expect(flash[:notice]).to be_present
    end
    
    it "cannot checkout with empty cart" do
      cart.cart_items.destroy_all
      post :create
      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to be_present
    end
    
    it "shows errors for invalid checkout info" do
      session[:checkout_address] = ''
      session[:checkout_phone] = ''
      post :create
      # Should redirect back or show errors
      expect(response).not_to redirect_to(customer_dashboard_path)
    end
    
    context "with credit card payment" do
      before do
        session[:checkout_payment_method] = 'credit_card'
      end
      
      it "redirects to payment page if payment not completed" do
        post :create
        expect(response).to redirect_to(checkout_payment_path)
      end
      
      it "creates paid order if payment is completed" do
        session[:payment_intent_id] = 'pi_test_1234567890'
        
        expect {
          post :create
        }.to change(Order, :count).by(1)
        
        order = Order.last
        expect(order.status).to eq('pending')
        expect(order.stripe_payment_intent_id).to eq('pi_test_1234567890')
      end
    end
  end
end
