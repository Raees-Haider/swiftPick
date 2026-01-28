require 'rails_helper'

RSpec.describe Product, type: :model do
  # Test data
  let(:category) { create(:category) }
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user: user) }
  
  # Helper methods
  def attach_test_image(product)
    png_data = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82"
    product.image.attach(
      io: StringIO.new(png_data),
      filename: 'test.png',
      content_type: 'image/png'
    )
  end
  
  def build_valid_product(attributes = {})
    product = build(:product, { category_id: category.id }.merge(attributes))
    attach_test_image(product) unless product.image.attached?
    product.categories << category unless product.categories.include?(category)
    product
  end
  
  describe 'associations' do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:product_categories).dependent(:destroy) }
    it { should have_many(:categories).through(:product_categories) }
  end

  describe 'validations' do
    describe 'name' do
      it { should validate_presence_of(:name) }
      
      it 'validates name minimum length' do
        product = build(:product, name: 'AB', category_id: category.id)
        expect(product).not_to be_valid
        expect(product.errors[:name]).to include("is too short (minimum is 3 characters)")
      end
      
      it 'validates name maximum length' do
        product = build(:product, name: 'A' * 101, category_id: category.id)
        expect(product).not_to be_valid
        expect(product.errors[:name]).to include("is too long (maximum is 100 characters)")
      end
      
      it 'accepts valid name length' do
        product = build_valid_product(name: 'Valid Product Name')
        expect(product).to be_valid
      end
    end

    describe 'description' do
      it { should validate_presence_of(:description) }
      
      it 'validates description minimum length' do
        product = build(:product, description: 'Short', category_id: category.id)
        expect(product).not_to be_valid
        expect(product.errors[:description]).to include("is too short (minimum is 10 characters)")
      end
      
      it 'accepts valid description length' do
        product = build_valid_product(description: 'This is a valid description that meets the minimum length requirement.')
        expect(product).to be_valid
      end
    end

    describe 'price' do
      it { should validate_presence_of(:price) }
      
      it 'validates price is a number' do
        product = build(:product, price: 'not_a_number', category_id: category.id)
        expect(product).not_to be_valid
        expect(product.errors[:price]).to be_present
      end
      
      it 'validates price is greater than or equal to 0' do
        product = build(:product, price: -10, category_id: category.id)
        expect(product).not_to be_valid
        expect(product.errors[:price]).to include("must be greater than or equal to 0")
      end
      
      it 'accepts zero price' do
        product = build_valid_product(price: 0)
        expect(product).to be_valid
      end
      
      it 'accepts positive price' do
        product = build_valid_product(price: 99.99)
        expect(product).to be_valid
      end
    end

    describe 'stock_quantity' do
      it { should validate_presence_of(:stock_quantity) }
      
      it 'validates stock_quantity is an integer' do
        product = build(:product, stock_quantity: 10.5, category_id: category.id)
        expect(product).not_to be_valid
        expect(product.errors[:stock_quantity]).to include("must be an integer")
      end
      
      it 'validates stock_quantity is greater than or equal to 0' do
        product = build(:product, stock_quantity: -1, category_id: category.id)
        expect(product).not_to be_valid
        expect(product.errors[:stock_quantity]).to include("must be greater than or equal to 0")
      end
      
      it 'accepts zero stock_quantity' do
        product = build_valid_product(stock_quantity: 0)
        expect(product).to be_valid
      end
      
      it 'accepts positive stock_quantity' do
        product = build_valid_product(stock_quantity: 100)
        expect(product).to be_valid
      end
    end

    describe 'active' do
      it 'validates active is boolean' do
        product = build(:product, active: nil, category_id: category.id)
        expect(product).not_to be_valid
        expect(product.errors[:active]).to include("is not included in the list")
      end
      
      it 'accepts true for active' do
        product = build_valid_product(active: true)
        expect(product).to be_valid
      end
      
      it 'accepts false for active' do
        product = build_valid_product(active: false)
        expect(product).to be_valid
      end
    end

    describe 'image' do
      it 'requires image for new products' do
        product = build(:product, category_id: category.id)
        product.image.detach if product.image.attached?
        product.categories << category
        expect(product).not_to be_valid
        expect(product.errors[:image]).to include("Please select an image file")
      end
      
      it 'does not require image for existing products' do
        product = create(:product, category_id: category.id)
        product.image.detach
        expect(product).to be_valid
      end
    end

    describe 'categories' do
      it 'requires at least one category' do
        product = build(:product, category_id: nil)
        attach_test_image(product)
        expect(product).not_to be_valid
        expect(product.errors[:categories]).to include("must have at least one category selected")
      end
      
      it 'accepts product with one category' do
        product = build_valid_product
        expect(product).to be_valid
      end
      
      it 'accepts product with multiple categories' do
        category2 = create(:category, name: 'Electronics')
        product = create(:product, category_id: category.id)
        product.categories << category2 unless product.categories.include?(category2)
        product.save
        product.reload
        expect(product.categories.count).to eq(2)
        expect(product.categories).to include(category, category2)
      end
    end
  end

  describe 'associations behavior' do
    let(:product) { create(:product, category_id: category.id) }
    
    describe 'cart_items' do
      it 'can have multiple cart_items' do
        cart_item1 = create(:cart_item, cart: cart, product: product)
        cart_item2 = create(:cart_item, cart: cart, product: product)
        
        expect(product.cart_items.count).to eq(2)
        expect(product.cart_items).to include(cart_item1, cart_item2)
      end
      
      it 'destroys cart_items when product is destroyed' do
        cart_item = create(:cart_item, cart: cart, product: product)
        
        expect { product.destroy }.to change { CartItem.count }.by(-1)
        expect(CartItem.find_by(id: cart_item.id)).to be_nil
      end
    end

    describe 'order_items' do
      let(:order) { create(:order, user: user) }
      
      it 'can have multiple order_items' do
        order_item1 = create(:order_item, order: order, product: product)
        order_item2 = create(:order_item, order: order, product: product)
        
        expect(product.order_items.count).to eq(2)
        expect(product.order_items).to include(order_item1, order_item2)
      end
      
      it 'destroys order_items when product is destroyed' do
        order_item = create(:order_item, order: order, product: product)
        
        expect { product.destroy }.to change { OrderItem.count }.by(-1)
        expect(OrderItem.find_by(id: order_item.id)).to be_nil
      end
    end

    describe 'categories' do
      it 'can belong to multiple categories' do
        category2 = create(:category, name: 'Electronics')
        product.categories << category2
        
        expect(product.categories.count).to eq(2)
        expect(product.categories).to include(category, category2)
      end
      
      it 'destroys product_categories when product is destroyed' do
        product_category = product.product_categories.first
        
        expect { product.destroy }.to change { ProductCategory.count }.by(-1)
        expect(ProductCategory.find_by(id: product_category.id)).to be_nil
      end
    end
  end

  describe 'factory' do
    subject(:product) { create(:product) }
    
    it { is_expected.to be_valid }
    it { is_expected.to be_persisted }
    it { expect(product.image).to be_attached }
    it { expect(product.categories).not_to be_empty }
    it { expect(product.category_id).not_to be_nil }
    
    context 'with inactive trait' do
      subject(:product) { create(:product, :inactive) }
      it { expect(product.active).to be false }
    end
    
    context 'with out_of_stock trait' do
      subject(:product) { create(:product, :out_of_stock) }
      it { expect(product.stock_quantity).to eq(0) }
    end
  end

  describe 'scopes and queries' do
    let!(:active_product) { create(:product, active: true) }
    let!(:inactive_product) { create(:product, :inactive) }
    
    it 'can filter active products' do
      active_products = Product.where(active: true)
      expect(active_products).to include(active_product)
      expect(active_products).not_to include(inactive_product)
    end
    
    it 'can filter inactive products' do
      inactive_products = Product.where(active: false)
      expect(inactive_products).to include(inactive_product)
      expect(inactive_products).not_to include(active_product)
    end
  end
end
