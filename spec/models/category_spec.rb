require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "associations" do
    it { should have_many(:product_categories).dependent(:destroy) }
    it { should have_many(:products).through(:product_categories) }
  end
  
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
  
  describe "product assignment" do
    let(:category) { create(:category) }
    let(:product) { create(:product, category_id: category.id) }
    
    it "assigns products to categories correctly" do
      # Product factory already adds the category, so just verify
      expect(category.products).to include(product)
      expect(product.categories).to include(category)
    end
    
    it "allows multiple categories per product" do
      category2 = create(:category)
      # Add second category (first already added by factory)
      product.categories << category2 unless product.categories.include?(category2)
      expect(product.categories.count).to eq(2)
      expect(product.categories).to include(category, category2)
    end
  end
  
  describe "filtering products" do
    let(:category1) { create(:category, name: "Electronics") }
    let(:category2) { create(:category, name: "Clothing") }
    let(:product1) { create(:product, category_id: category1.id) }
    let(:product2) { create(:product, category_id: category2.id) }
    
    it "returns only products in the category" do
      # Factory already adds categories, so just verify
      expect(category1.products).to include(product1)
      expect(category1.products).not_to include(product2)
      expect(category2.products).to include(product2)
      expect(category2.products).not_to include(product1)
    end
  end
  
  describe "products without categories" do
    let(:category) { create(:category) }
    let(:product) { create(:product, category_id: category.id) }
    
    it "products have at least one category from factory" do
      # Factory ensures products have at least one category
      expect(product.categories).not_to be_empty
      expect(product.categories.first).to eq(category)
    end
  end
end
