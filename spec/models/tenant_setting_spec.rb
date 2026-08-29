require 'rails_helper'

RSpec.describe TenantSetting, type: :model do
  describe "associations" do
    it { should belong_to(:tenant) }
  end

  describe "validations" do
    it { should validate_presence_of(:cancellation_window_hours) }
    it { should validate_numericality_of(:cancellation_window_hours).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:reminder_hours) }
    it { should validate_numericality_of(:reminder_hours).is_greater_than(0) }
    it { should validate_presence_of(:notification_channels) }
  end

  describe "#notification_channels_array" do
    it "returns an array of channels from comma-separated string" do
      setting = build(:tenant_setting, notification_channels: "email, whatsapp")
      expect(setting.notification_channels_array).to eq([ "email", "whatsapp" ])
    end

    it "defaults to email if empty" do
      setting = build(:tenant_setting, notification_channels: "email")
      expect(setting.notification_channels_array).to eq([ "email" ])
    end
  end
end
