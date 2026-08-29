require 'rails_helper'

RSpec.describe Notifications::Dispatcher do
  let(:tenant) { create(:tenant) }
  let(:client) { create(:client, tenant: tenant, email: "cliente@teste.com") }
  let(:appointment) { create(:appointment, tenant: tenant, client: client) }

  describe "#dispatch" do
    it "creates a pending Notification and enqueues SendNotificationJob" do
      expect {
        described_class.new(appointment).dispatch(:confirmation)
      }.to change(Notification, :count).by(1).and have_enqueued_job(SendNotificationJob)

      notification = Notification.last
      expect(notification.appointment).to eq(appointment)
      expect(notification.notification_type).to eq("confirmation")
      expect(notification.status).to eq("pending")
    end
  end
end
