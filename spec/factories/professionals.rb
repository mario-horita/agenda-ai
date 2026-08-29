FactoryBot.define do
  factory :professional do
    tenant
    name { Faker::Name.name }
    sequence(:email) { |n| "prof#{n}@example.com" }
    phone { "(11) 98888-7777" }
    bio { "Especialista com vasta experiência" }
    buffer_minutes { 10 }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
