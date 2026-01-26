require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    
    it 'validates name length' do
      user = build(:user, name: 'A')
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("must be between 2 and 50 characters")
      
      user = build(:user, name: 'A' * 51)
      expect(user).not_to be_valid
    end
    
    it 'validates password length' do
      user = build(:user, password: '12345', password_confirmation: '12345')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must be at least 6 characters")
    end
  end
  
  describe 'associations' do
    it { should have_one(:cart) }
    it { should have_many(:orders) }
  end
  
  describe 'password reset methods' do
    it 'generates password reset token' do
      user = create(:user)
      
      # Clear any existing token
      user.update_columns(password_reset_token: nil, password_reset_sent_at: nil)
      user.reload
      initial_token = user.password_reset_token
      user.generate_password_reset_token!
      user.reload
      expect(user.password_reset_token).not_to be_nil
      expect(user.password_reset_sent_at).not_to be_nil
    end
    
    it 'clears password reset token' do
      user = create(:user)
      
      # Clear any existing token first
      user.update_columns(password_reset_token: nil, password_reset_sent_at: nil)
      user.reload
      user.generate_password_reset_token!
      user.reload
      expect(user.password_reset_token).not_to be_nil
      user.clear_password_reset_token!
      db_user = User.find(user.id)
      expect(db_user.password_reset_sent_at).to be_nil
    end
    
    it 'checks if password reset expired' do
      user = create(:user)
      user.generate_password_reset_token!
      user.reload
      expect(user.password_reset_expired?).to be false
      
      user.update_columns(password_reset_sent_at: 2.hours.ago)
      user.reload
      expect(user.password_reset_expired?).to be true
    end
  end
  
  describe 'role methods' do
    it 'returns true for admin? when role is admin' do
      user = create(:user, :admin)
      expect(user.admin?).to be true
    end
    
    it 'returns true for customer? when role is customer' do
      user = create(:user, :customer)
      expect(user.customer?).to be true
    end
  end
end
