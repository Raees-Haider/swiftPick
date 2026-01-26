class RegistrationsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = "customer"  # all signup are by default customers

    if @user.save
      session[:user_id] = @user.id
      redirect_to customer_dashboard_path, notice: "Account created successfully! Welcome, #{@user.name}!"
    else
      flash.now[:alert] = "Please fix the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def redirect_if_logged_in
    if current_user
      redirect_to customer_dashboard_path, notice: "You are already logged in."
    end
  end
end
