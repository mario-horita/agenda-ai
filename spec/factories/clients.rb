FactoryBot.define do
  factory :client do
    tenant
    name { Faker::Name.name }
    sequence(:email) { |n| "client#{n}@example.com" }
    phone { "(11) 97777-6666" }
  end
end
