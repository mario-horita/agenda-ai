FactoryBot.define do
  factory :availability do
    professional
    day_of_week { 1 }
    start_time { Time.zone.parse("09:00") }
    end_time { Time.zone.parse("18:00") }
  end
end
