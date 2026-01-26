require "rails_helper"

RSpec.describe PasswordResetMailer, type: :mailer do
  describe "reset_password" do
    let(:user) { create(:user, email: 'test@example.com', name: 'Test User') }
    let(:mail) { PasswordResetMailer.reset_password(user) }

    before do
      user.generate_password_reset_token!
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Reset Your Password")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@ecommerce.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Password Reset Request")
      expect(mail.body.encoded).to match(user.name)
      expect(mail.body.encoded).to match(edit_password_reset_path(user.reset_token))
    end
  end
end
