require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe "associations" do
    it { should belong_to(:tenant) }
    it { should belong_to(:professional) }
    it { should belong_to(:service) }
    it { should belong_to(:client).counter_cache(true) }
  end

  describe "validations" do
    subject { build(:appointment) }

    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }
    it { should validate_presence_of(:status) }
    it { should validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }

    it "validates that ends_at is after starts_at" do
      now = Time.current
      valid = build(:appointment, starts_at: now, ends_at: now + 30.minutes)
      expect(valid).to be_valid

      invalid = build(:appointment, starts_at: now + 30.minutes, ends_at: now)
      expect(invalid).not_to be_valid
      expect(invalid.errors[:ends_at]).to include("deve ser posterior ao horário de início")
    end
  end

  describe "enums" do
    it "defines expected status values" do
      expect(Appointment.statuses.keys).to contain_exactly("pending", "confirmed", "completed", "cancelled", "no_show")
    end
  end

  describe "callbacks" do
    it "generates a UUID on create" do
      appointment = create(:appointment)
      expect(appointment.id).to be_present
      expect(appointment.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "multi-tenancy" do
    let(:tenant1) { create(:tenant) }
    let(:tenant2) { create(:tenant) }
    let!(:appt1) { create(:appointment, tenant: tenant1) }
    let!(:appt2) { create(:appointment, tenant: tenant2) }

    it "scopes appointments to current tenant" do
      ActsAsTenant.with_tenant(tenant1) do
        expect(Appointment.all).to include(appt1)
        expect(Appointment.all).not_to include(appt2)
      end
    end
  end
end
