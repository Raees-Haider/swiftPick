class CheckoutController < ApplicationController
  before_action :require_login
  before_action :setup_checkout
  
  TAX_RATE = 0.18
  SHIPPING_COST = 150
  
  def new
    @step = params[:step] || 'address'
    @shipping_address = session[:checkout_address] || ''
    @phone = session[:checkout_phone] || ''
    @payment_method = session[:checkout_payment_method] || ''
  end
  
  def update_step
    case params[:step]
    when 'address'
      handle_address_step
    when 'payment'
      handle_payment_step
    end
  end
  
  def payment
    return if session[:checkout_payment_method] == 'credit_card'
    
    redirect_to checkout_path(step: 'review'), alert: "Invalid payment method"
  end
  
  def create_payment_intent
    return render_error("Your cart is empty") if @cart_items.empty?
    
    # Check if Stripe is configured
    unless Stripe.api_key.present?
      Rails.logger.error "Stripe API key is not configured"
      return render json: { error: "Stripe is not configured. Please contact support." }, status: :internal_server_error
    end
    
    begin
      amount = calculate_amount_in_cents
      Rails.logger.info "Creating payment intent for amount: #{amount} cents"
      
      payment_intent = Stripe::PaymentIntent.create(
        amount: amount,
        currency: 'pkr',
        payment_method_types: ["card"],
        metadata: { user_id: current_user.id }
      )
      
      Rails.logger.info "Payment intent created: #{payment_intent.id}"
      render json: { clientSecret: payment_intent.client_secret }
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error: #{e.class} - #{e.message}"
      render json: { error: e.message }, status: :bad_request
    rescue => e
      Rails.logger.error "Unexpected error creating payment intent: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "An unexpected error occurred. Please try again." }, status: :internal_server_error
    end
  end
  
  def complete_payment
    payment_intent_id = params[:payment_intent_id]
    
    return redirect_with_error(checkout_payment_path, "Payment information is missing") unless payment_intent_id.present?
    
    verify_and_create_order(payment_intent_id)
  rescue Stripe::StripeError => e
    log_error("Stripe error in complete_payment", e)
    redirect_with_error(checkout_payment_path, "Payment verification failed: #{e.message}")
  rescue => e
    log_error("Unexpected error in complete_payment", e)
    redirect_with_error(checkout_payment_path, "An unexpected error occurred. Please try again.")
  end
  
  def create
    return redirect_with_error(checkout_payment_path) if requires_payment? && !payment_completed?
    
    create_order_with_items
    return if performed? # Already redirected due to validation errors
    
    clear_checkout_session
    redirect_to customer_dashboard_path, notice: "Order placed successfully!"
  end
  
  private
  
  def setup_checkout
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(:product) if @cart.persisted?
    
    return redirect_with_error(cart_path, "Your cart is empty") if @cart_items.blank?
    
    calculate_totals
  end
  
  def handle_address_step
    session[:checkout_address] = params[:shipping_address]
    session[:checkout_phone] = params[:phone]
    
    if params[:shipping_address].blank? || params[:phone].blank?
      redirect_to checkout_path(step: 'address'), alert: "Please fill in all required fields"
      return
    end
    
    redirect_to checkout_path(step: 'payment')
  end
  
  def handle_payment_step
    session[:checkout_payment_method] = params[:payment_method]
    
    if params[:payment_method].blank?
      redirect_to checkout_path(step: 'payment'), alert: "Please select a payment method"
      return
    end
    
    redirect_to checkout_path(step: 'review')
  end
  
  def verify_and_create_order(payment_intent_id)
    payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
    
    unless payment_intent.status == 'succeeded'
      Rails.logger.error "Payment Intent status is not succeeded: #{payment_intent.status}"
      return redirect_with_error(checkout_payment_path, "Payment was not successful. Status: #{payment_intent.status}. Please try again.")
    end
    
    session[:payment_intent_id] = payment_intent_id
    create_order_with_items(status: 'pending', stripe_payment_intent_id: payment_intent_id)
    clear_checkout_session
    redirect_to customer_dashboard_path, notice: "Order placed successfully! Payment completed."
  end
  
  def create_order_with_items(status: nil, stripe_payment_intent_id: nil)
    total = calculate_total
    
    @order = current_user.orders.create(
      status: status || 'pending',
      total_amount: total,
      shipping_address: session[:checkout_address],
      phone: session[:checkout_phone],
      payment_method: session[:checkout_payment_method],
      stripe_payment_intent_id: stripe_payment_intent_id || session[:payment_intent_id]
    )
    
    # Only create order items if order was saved successfully
    unless @order.persisted?
      flash[:alert] = @order.errors.full_messages.join(", ")
      redirect_to checkout_path(step: 'review') and return
    end
    
    create_order_items
    update_product_stock
    clear_cart
  end
  
  def create_order_items
    @cart_items.each do |cart_item|
      @order.order_items.create(
        product: cart_item.product,
        quantity: cart_item.quantity,
        price: cart_item.product.price
      )
    end
  end
  
  def update_product_stock
    @cart_items.each do |cart_item|
      cart_item.product.decrement!(:stock_quantity, cart_item.quantity)
    end
  end
  
  def clear_cart
    @cart.cart_items.destroy_all
  end
  
  def clear_checkout_session
    session[:checkout_address] = nil
    session[:checkout_phone] = nil
    session[:checkout_payment_method] = nil
    session[:payment_intent_id] = nil
  end
  
  def calculate_totals
    @subtotal = calculate_subtotal
    @tax = calculate_tax(@subtotal)
    @shipping = SHIPPING_COST
    @total = calculate_total
  end
  
  def calculate_subtotal
    @cart_items.sum { |item| item.product.price * item.quantity }
  end
  
  def calculate_tax(subtotal)
    subtotal * TAX_RATE
  end
  
  def calculate_total
    subtotal = calculate_subtotal
    subtotal + calculate_tax(subtotal) + SHIPPING_COST
  end
  
  def calculate_amount_in_cents
    (@total * 100).to_i
  end
  
  def requires_payment?
    session[:checkout_payment_method] == 'credit_card'
  end
  
  def payment_completed?
    session[:payment_intent_id].present?
  end
  
  def render_error(message)
    render json: { error: message }, status: :bad_request
  end
  
  def redirect_with_error(path, message = nil)
    redirect_to path, alert: message
  end
  
  def log_error(message, error)
    Rails.logger.error "#{message}: #{error.message}"
    Rails.logger.error error.backtrace.join("\n") if error.respond_to?(:backtrace)
  end
end
