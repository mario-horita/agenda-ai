FactoryBot.define do
  factory :tenant_setting do
    tenant
    cancellation_window_hours { 24 }
    allow_reschedule { true }
    reminder_hours { 24 }
    notification_channels { "email" }
  end
end
