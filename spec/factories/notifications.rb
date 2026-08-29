FactoryBot.define do
  factory :notification do
    appointment
    channel { "email" }
    notification_type { "confirmation" }
    status { "pending" }

    trait :sent do
      status { "sent" }
      sent_at { Time.current }
    end

    trait :failed do
      status { "failed" }
    end
  end
end
