require 'rails_helper'

RSpec.describe Tenant, type: :model do
  describe "associations" do
    it { should have_many(:users).dependent(:destroy) }
    it { should have_one(:tenant_setting).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:tenant) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug).case_insensitive }
    it { should validate_presence_of(:plan) }
    it { should validate_presence_of(:timezone) }

    it "accepts valid slug formats" do
      valid_slugs = [ "salao-demo", "barbearia123", "clinica-dr-silva" ]
      valid_slugs.each do |slug|
        tenant = build(:tenant, slug: slug)
        expect(tenant).to be_valid
      end
    end

    it "rejects invalid slug formats" do
      invalid_slugs = [ "Salao Demo", "barbearia_123", "clinica!", "ab", "a" * 64 ]
      invalid_slugs.each do |slug|
        tenant = build(:tenant, slug: slug)
        expect(tenant).not_to be_valid
      end
    end

    it "validates inclusion of plan" do
      expect(build(:tenant, plan: "starter")).to be_valid
      expect(build(:tenant, plan: "pro")).to be_valid
      expect(build(:tenant, plan: "enterprise")).to be_valid
      expect { build(:tenant, plan: "invalid_plan") }.to raise_error(ArgumentError)
    end
  end

  describe "callbacks" do
    it "generates a UUID on create" do
      tenant = create(:tenant)
      expect(tenant.id).to be_present
      expect(tenant.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end

    it "normalizes slug to lowercase and trimmed" do
      tenant = create(:tenant, slug: "  Meu-Salao  ")
      expect(tenant.slug).to eq("meu-salao")
    end

    it "creates default tenant settings on create" do
      tenant = create(:tenant)
      expect(tenant.tenant_setting).to be_present
      expect(tenant.tenant_setting.cancellation_window_hours).to eq(24)
      expect(tenant.tenant_setting.notification_channels).to eq("email")
    end
  end
end
