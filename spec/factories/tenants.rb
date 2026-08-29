FactoryBot.define do
  factory :tenant do
    name { Faker::Company.name }
    sequence(:slug) { |n| "empresa-#{n}-#{SecureRandom.hex(3)}" }
    timezone { "America/Sao_Paulo" }
    phone { "(11) 98765-4321" }
    plan { "starter" }
    primary_color { "#6366f1" }
    secondary_color { "#8b5cf6" }

    trait :pro do
      plan { "pro" }
      trial_ends_at { 14.days.from_now }
    end

    trait :enterprise do
      plan { "enterprise" }
    end
  end
end
