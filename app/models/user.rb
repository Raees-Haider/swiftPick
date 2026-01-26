class User < ApplicationRecord
  attr_accessor :reset_token
  has_secure_password

  has_one :cart
  has_many :orders
  has_many :addresses

  # Validations
  validates :name, presence: { message: "can't be blank" }, 
                   length: { minimum: 2, maximum: 50, message: "must be between 2 and 50 characters" }
  
  validates :email, presence: { message: "can't be blank" },
                    uniqueness: { case_sensitive: false, message: "has already been taken" },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "is invalid" }
  
  validates :password, length: { minimum: 6, message: "must be at least 6 characters" },
                       if: -> { new_record? || !password.nil? }


  def generate_password_reset_token!
  self.reset_token = SecureRandom.urlsafe_base64(32)
  self.password_reset_token = Digest::SHA256.hexdigest(reset_token)
  self.password_reset_sent_at = Time.current
  save!(validate: false)
end




  def clear_password_reset_token!
    self.password_reset_token = nil
    self.password_reset_sent_at = nil
    save!(validate: false)
  end

  def password_reset_expired?
    password_reset_sent_at.blank? || password_reset_sent_at < 1.hour.ago
  end


  def admin?
    role == "admin"
  end

  def customer?
    role == "customer"
  end

  def display_name
    name.presence || email
  end
end

