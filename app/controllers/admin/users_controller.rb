class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:destroy]  

  def index
    @users = User.where(role: 'customer').order(created_at: :desc)
  end

  def destroy
    if @user.nil?
      redirect_to admin_users_path, alert: "User not found."
      return
    end

    if @user.admin?
      redirect_to admin_users_path, alert: "Cannot delete an admin user."
    else
      @user.destroy
      redirect_to admin_users_path, notice: "User deleted successfully."
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])  
  end
end
