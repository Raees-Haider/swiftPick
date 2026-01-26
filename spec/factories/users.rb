FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { "customer" }
    
    trait :admin do
      role { "admin" }
    end
    
    trait :customer do
      role { "customer" }
    end
  end
end
