class ApplicationController < ActionController::Base
 allow_browser versions: :modern

 stale_when_importmap_changes

  helper_method :current_user, :current_cart, :show_navbar?

  def current_user
    return unless session[:user_id]
    
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    redirect_to login_path, alert: "Please log in first" unless current_user
  end

  def current_cart
    if current_user
      find_or_create_user_cart
    else
      find_or_create_guest_cart
    end
  end

  def find_or_create_user_cart
    cart = current_user.cart || current_user.create_cart
    session[:cart_id] = cart.id
    cart
  end

  def find_or_create_guest_cart
    cart = Cart.find_by(id: session[:cart_id]) if session[:cart_id]
    return cart if cart

    cart = Cart.create(user_id: nil)
    session[:cart_id] = cart.id
    cart
  end

  def require_admin
    return if current_user&.admin?

    redirect_to login_path, alert: "Access denied"
  end

  # Determines if the navbar should be shown
  def show_navbar?
    return false if auth_controller? || admin_path?

    true
  end

  def auth_controller?
    %w[sessions registrations password_resets].include?(controller_name)
  end

  def admin_path?
    controller_path.start_with?("admin/")
  end
  
end
