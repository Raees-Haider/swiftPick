require 'rails_helper'
require_relative '../support/stripe_helper'

RSpec.describe CheckoutController, type: :controller do
  include StripeHelper
  
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:product) { create(:product, category_id: category.id, price: 100.0) }
  let(:cart) { create(:cart, user: user) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }
  
  before do
    session[:user_id] = user.id
    session[:cart_id] = cart.id
    session[:checkout_payment_method] = 'credit_card'
    session[:checkout_address] = '123 Test St'
    session[:checkout_phone] = '1234567890'
  end
  
  describe "POST #create_payment_intent" do
    it "creates Stripe payment intent correctly" do
      mock_payment_intent = double(
        id: 'pi_test_123',
        client_secret: 'pi_test_123_secret',
        amount: 10000,
        currency: 'pkr',
        status: 'requires_payment_method'
      )
      
      allow(Stripe::PaymentIntent).to receive(:create).and_return(mock_payment_intent)
      
      post :create_payment_intent
      
      expect(Stripe::PaymentIntent).to have_received(:create).with(
        hash_including(
          currency: 'pkr',
          payment_method_types: ['card'],
          metadata: hash_including(user_id: user.id)
        )
      )
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['clientSecret']).to eq('pi_test_123_secret')
    end
    
    it "returns error if cart is empty" do
      cart.cart_items.destroy_all
      post :create_payment_intent
      # setup_checkout redirects when cart is empty
      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to include("Your cart is empty")
    end
  end
  
  describe "POST #complete_payment" do
    context "with successful payment" do
      it "creates order with pending status" do
        mock_payment_intent = double(
          id: 'pi_test_123',
          status: 'succeeded',
          amount: 10000,
          currency: 'pkr'
        )
        
        allow(Stripe::PaymentIntent).to receive(:retrieve).and_return(mock_payment_intent)
        
        expect {
          post :complete_payment, params: { payment_intent_id: 'pi_test_123' }
        }.to change(Order, :count).by(1)
        
        order = Order.last
        expect(order.status).to eq('pending')
        expect(order.stripe_payment_intent_id).to eq('pi_test_123')
      end
      
      it "redirects to dashboard on success" do
        mock_payment_intent = double(
          id: 'pi_test_123',
          status: 'succeeded',
          amount: 10000,
          currency: 'pkr'
        )
        
        allow(Stripe::PaymentIntent).to receive(:retrieve).and_return(mock_payment_intent)
        
        post :complete_payment, params: { payment_intent_id: 'pi_test_123' }
        expect(response).to redirect_to(customer_dashboard_path)
        expect(flash[:notice]).to be_present
      end
    end
    
    context "with failed payment" do
      it "does not create order" do
        mock_payment_intent = double(
          id: 'pi_test_123',
          status: 'requires_payment_method',
          amount: 10000,
          currency: 'pkr'
        )
        
        allow(Stripe::PaymentIntent).to receive(:retrieve).and_return(mock_payment_intent)
        
        expect {
          post :complete_payment, params: { payment_intent_id: 'pi_test_123' }
        }.not_to change(Order, :count)
      end
      
      it "redirects with error message" do
        mock_payment_intent = double(
          id: 'pi_test_123',
          status: 'requires_payment_method',
          amount: 10000,
          currency: 'pkr'
        )
        
        allow(Stripe::PaymentIntent).to receive(:retrieve).and_return(mock_payment_intent)
        
        post :complete_payment, params: { payment_intent_id: 'pi_test_123' }
        expect(response).to redirect_to(checkout_payment_path)
        expect(flash[:alert]).to be_present
      end
    end
    
    context "with missing payment intent" do
      it "redirects with error" do
        post :complete_payment, params: {}
        expect(response).to redirect_to(checkout_payment_path)
        expect(flash[:alert]).to be_present
      end
    end
    
    context "with Stripe error" do
      it "handles Stripe errors gracefully" do
        allow(Stripe::PaymentIntent).to receive(:retrieve).and_raise(Stripe::StripeError.new("Invalid payment intent"))
        
        post :complete_payment, params: { payment_intent_id: 'invalid' }
        expect(response).to redirect_to(checkout_payment_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
