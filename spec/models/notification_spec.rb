require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { should belong_to(:appointment) }
  end

  describe "validations" do
    subject { build(:notification) }

    it { should validate_presence_of(:channel) }
    it { should validate_presence_of(:notification_type) }
    it { should validate_presence_of(:status) }
  end

  describe "enums" do
    it "defines expected channel values" do
      expect(Notification.channels.keys).to contain_exactly("email", "whatsapp")
    end

    it "defines expected notification_type values" do
      expect(Notification.notification_types.keys).to contain_exactly("confirmation", "reminder_24h", "reminder_2h", "cancellation", "reschedule")
    end

    it "defines expected status values" do
      expect(Notification.statuses.keys).to contain_exactly("pending", "sent", "failed")
    end
  end

  describe "callbacks" do
    it "generates a UUID on create" do
      notification = create(:notification)
      expect(notification.id).to be_present
      expect(notification.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end
end
