require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:product1) { create(:product, category_id: category.id, price: 100.0) }
  let(:product2) { create(:product, category_id: category.id, price: 200.0) }
  let(:order) { create(:order, user: user) }
  
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:products).through(:order_items) }
  end
  
  describe "validations" do
    subject { build(:order, user: user) }
    it { should validate_presence_of(:shipping_address) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:total_amount) }
  end
  
  describe "order creation" do
    it "is created after successful checkout" do
      expect {
        create(:order, user: user)
      }.to change(Order, :count).by(1)
    end
    
    it "stores order information correctly" do
      order = create(:order,
        user: user,
        shipping_address: "123 Test St",
        phone: "1234567890",
        total_amount: 500.0
      )
      expect(order.shipping_address).to eq("123 Test St")
      expect(order.phone).to eq("1234567890")
      expect(order.total_amount).to eq(500.0)
    end
  end
  
  describe "order items" do
    it "products in order match cart contents" do
      order_item1 = create(:order_item, order: order, product: product1, quantity: 2, price: product1.price)
      order_item2 = create(:order_item, order: order, product: product2, quantity: 1, price: product2.price)
      
      expect(order.order_items.count).to eq(2)
      expect(order.order_items).to include(order_item1, order_item2)
    end
  end
  
  describe "order status" do
    it "has default status of pending" do
      order = create(:order, user: user)
      expect(order.status).to eq('pending')
    end
    
    it "changes status correctly" do
      order = create(:order, user: user, status: 'pending')
      order.update(status: 'shipped')
      expect(order.status).to eq('shipped')
      
      order.update(status: 'completed')
      expect(order.status).to eq('completed')
    end
    
    it "can be marked as paid" do
      order = create(:order, user: user, status: 'paid')
      expect(order.status).to eq('paid')
    end
    
    describe "#completed?" do
      it "returns true when status is completed" do
        order = create(:order, user: user, status: 'completed')
        expect(order.completed?).to be true
      end
      
      it "returns false when status is not completed" do
        order = create(:order, user: user, status: 'pending')
        expect(order.completed?).to be false
        
        order.update(status: 'shipped')
        expect(order.completed?).to be false
      end
    end
  end
  
  describe "user order history" do
    let(:other_user) { create(:user) }
    
    it "user can view only their own orders" do
      user_order = create(:order, user: user)
      other_order = create(:order, user: other_user)
      
      user_orders = Order.where(user: user)
      expect(user_orders).to include(user_order)
      expect(user_orders).not_to include(other_order)
    end
  end
end
