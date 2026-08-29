require 'rails_helper'

RSpec.describe Notifications::ReminderScheduler do
  let(:tenant) { create(:tenant) }
  let(:client) { create(:client, tenant: tenant, email: "cliente@teste.com") }
  let(:appointment) { create(:appointment, tenant: tenant, client: client, starts_at: 48.hours.from_now) }

  describe "#schedule" do
    it "schedules 24h and 2h reminders" do
      expect {
        described_class.new(appointment).schedule
      }.to change(Notification, :count).by(2)

      notifications = Notification.where(appointment: appointment)
      expect(notifications.pluck(:notification_type)).to contain_exactly("reminder_24h", "reminder_2h")
      expect(notifications.pluck(:status).uniq).to eq([ "pending" ])
    end
  end
end
