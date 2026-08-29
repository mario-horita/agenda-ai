FactoryBot.define do
  factory :service do
    tenant
    name { "Corte de Cabelo Masculino" }
    description { "Corte moderno com tesoura e máquina" }
    duration_minutes { 30 }
    price_cents { 5000 }
    currency { "BRL" }
    active { true }
    sequence(:sort_order) { |n| n }

    trait :inactive do
      active { false }
    end
  end
end
