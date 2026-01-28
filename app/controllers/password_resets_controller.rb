class PasswordResetsController < ApplicationController
  before_action :load_user_from_token, only: [:edit, :update]
  before_action :validate_token, only: [:edit, :update]

  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)
    if user
      user.generate_password_reset_token!
      PasswordResetMailer.reset_password(user).deliver_now
    end
    redirect_to login_path, notice: "If your email exists, a password reset link has been sent."
  end


  def edit
  end

  def update
    if @user.update(password_reset_params)
      @user.clear_password_reset_token!
      redirect_to login_path,
                  notice: "Password has been reset successfully. Please login."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_user_from_token
    token = params[:token]
    hashed_token = Digest::SHA256.hexdigest(token)
    @user = User.find_by(password_reset_token: hashed_token)
  end

  def validate_token
    if @user.nil?
      redirect_to login_path, alert: "Invalid password reset link"
    elsif @user.password_reset_expired?
      redirect_to login_path,
                  alert: "Password reset link has expired. Please request a new one."
    end
  end

  def password_reset_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
