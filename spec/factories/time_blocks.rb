FactoryBot.define do
  factory :time_block do
    professional
    start_date { Date.current + 1.day }
    end_date { Date.current + 1.day }
    start_time { Time.zone.parse("10:00") }
    end_time { Time.zone.parse("12:00") }
    reason { "Consulta Médica" }
    all_day { false }

    trait :all_day do
      all_day { true }
      start_time { nil }
      end_time { nil }
    end
  end
end
