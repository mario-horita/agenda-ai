require 'rails_helper'

RSpec.describe SendNotificationJob, type: :job do
  let(:tenant) { create(:tenant) }
  let(:client) { create(:client, tenant: tenant, email: "cliente@teste.com") }
  let(:appointment) { create(:appointment, tenant: tenant, client: client) }
  let(:notification) { create(:notification, appointment: appointment, channel: "email", notification_type: "confirmation", status: "pending") }

  describe "#perform" do
    it "delivers the confirmation email and marks notification as sent" do
      expect {
        described_class.new.perform(notification.id)
      }.to change { ActionMailer::Base.deliveries.count }.by_at_least(1)

      notification.reload
      expect(notification.status).to eq("sent")
      expect(notification.sent_at).to be_present
    end
  end
end
