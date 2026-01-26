class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
  end

  def create
    email = params[:email]&.downcase&.strip
    password = params[:password]

    errors = []
    errors << "Email is required" if email.blank?
    errors << "Password is required" if password.blank?
    
    if email.present? && !valid_email?(email)
      errors << "Please enter a valid email address"
    end

    if password.present? && password.length < 6
      errors << "Password must be at least 6 characters"
    end

    if errors.any?
      flash[:alert] = errors.join(", ")
      return render :new
    end

    user = User.find_by(email: email)
    if user && user.authenticate(password)
      session[:user_id] = user.id
      
      if params[:remember_me] == "1"
        request.session_options[:expire_after] = 30.days
      end
      
      redirect_path = user.admin? ? admin_root_path : customer_dashboard_path
      redirect_to redirect_path, notice: "Welcome back, #{user.display_name}!"
    else
      flash[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "You have been logged out successfully"
  end

  private

  def valid_email?(email)
    email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  end

  def redirect_if_logged_in
    return unless current_user

    redirect_path = current_user.admin? ? admin_root_path : customer_dashboard_path
    redirect_to redirect_path, alert: "You are already logged in."
  end
end
