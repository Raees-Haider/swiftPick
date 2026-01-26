module StripeHelper
  def mock_stripe_payment_intent_create(amount:, currency: 'pkr', status: 'succeeded')
    payment_intent = double('Stripe::PaymentIntent',
      id: "pi_test_#{SecureRandom.hex(10)}",
      client_secret: "pi_test_#{SecureRandom.hex(10)}_secret",
      status: status,
      amount: amount,
      currency: currency
    )
    
    allow(Stripe::PaymentIntent).to receive(:create).and_return(payment_intent)
    payment_intent
  end
  
  def mock_stripe_payment_intent_retrieve(payment_intent_id:, status: 'succeeded')
    payment_intent = double('Stripe::PaymentIntent',
      id: payment_intent_id,
      status: status,
      amount: 10000,
      currency: 'pkr'
    )
    
    allow(Stripe::PaymentIntent).to receive(:retrieve).with(payment_intent_id).and_return(payment_intent)
    payment_intent
  end
  
  def mock_stripe_error(error_type: Stripe::CardError, message: 'Your card was declined.')
    # Create a proper Stripe error instance
    # Stripe::StripeError.new(message, http_body, http_status, json_body)
    error_instance = error_type.new(message, { error: { message: message } }.to_json)
    allow(Stripe::PaymentIntent).to receive(:create).and_raise(error_instance)
    error_instance
  end
end

RSpec.configure do |config|
  config.include StripeHelper
end
