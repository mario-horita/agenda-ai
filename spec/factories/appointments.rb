FactoryBot.define do
  factory :appointment do
    tenant
    professional { association :professional, tenant: tenant }
    service { association :service, tenant: tenant }
    client { association :client, tenant: tenant }

    starts_at { Time.current.beginning_of_day + 1.day + 10.hours }
    ends_at { starts_at + 30.minutes }
    status { "confirmed" }
    price_cents { 5000 }
    lock_version { 0 }

    trait :pending do
      status { "pending" }
    end

    trait :cancelled do
      status { "cancelled" }
      cancelled_at { Time.current }
      cancelled_by { "client" }
      cancellation_reason { "Imprevisto" }
    end

    trait :completed do
      status { "completed" }
    end

    trait :no_show do
      status { "no_show" }
    end
  end
end
