class PasswordResetMailer < ApplicationMailer
  def reset_password(user)
    @user = user
    @reset_token = user.reset_token
    @reset_link = edit_password_reset_url(@reset_token)
    mail(to: @user.email, subject: "Reset Your Password")
  end
end

