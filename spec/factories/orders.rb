FactoryBot.define do
  factory :order do
    association :user
    status { "pending" }
    total_amount { 1000.0 }
    shipping_address { Faker::Address.full_address }
    phone { Faker::PhoneNumber.phone_number }
    payment_method { "cash_on_delivery" }
    
    trait :paid do
      status { "paid" }
      payment_method { "credit_card" }
      stripe_payment_intent_id { "pi_test_1234567890" }
    end
    
    trait :with_items do
      after(:create) do |order|
        create_list(:order_item, 2, order: order)
      end
    end
  end
end
