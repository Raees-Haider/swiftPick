FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    quantity { Faker::Number.between(from: 1, to: 5) }
    price { Faker::Commerce.price(range: 100.0..5000.0) }
  end
end
