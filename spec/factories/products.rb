FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    price { Faker::Commerce.price(range: 100.0..10000.0) }
    stock_quantity { Faker::Number.between(from: 1, to: 100) }
    active { true }
    
    transient do
      category { nil }
      category_id { nil }
    end
    
    before(:create) do |product, evaluator|
      # Attach a test image using a simple 1x1 pixel PNG
      unless product.image.attached?
        # Create a minimal valid PNG image
        require 'stringio'
        png_data = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82"
        product.image.attach(
          io: StringIO.new(png_data),
          filename: 'test_image.png',
          content_type: 'image/png'
        )
      end
      
      # Determine which category to use
      category = if evaluator.category_id
                   Category.find(evaluator.category_id)
                 elsif evaluator.category
                   evaluator.category
                 else
                   Category.first || create(:category)
                 end
      
      # Set category_id directly (database column requirement)
      product.category_id = category.id
      
      # Also add to categories association for validation (must be done before save)
      # Use assign_attributes or direct assignment to avoid validation issues
      product.categories << category unless product.categories.include?(category)
    end
    
    
    trait :inactive do
      active { false }
    end
    
    trait :out_of_stock do
      stock_quantity { 0 }
    end
  end
end
