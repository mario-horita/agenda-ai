FactoryBot.define do
  factory :user do
    tenant
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    role { "admin" }

    trait :manager do
      role { "manager" }
    end
  end
end
