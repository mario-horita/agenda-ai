require 'rails_helper'

RSpec.describe Service, type: :model do
  describe "associations" do
    it { should belong_to(:tenant) }
    it { should have_many(:professional_services).dependent(:destroy) }
    it { should have_many(:professionals).through(:professional_services) }
  end

  describe "validations" do
    subject { build(:service) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:duration_minutes) }
    it { should validate_numericality_of(:duration_minutes).is_greater_than(0) }
    it { should validate_presence_of(:price_cents) }
    it { should validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:currency) }
  end

  describe "callbacks" do
    it "generates a UUID on create" do
      service = create(:service)
      expect(service.id).to be_present
      expect(service.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "price helpers" do
    let(:service) { build(:service, price_cents: 6550) }

    it "converts price_cents to reais" do
      expect(service.price_in_reais).to eq(65.50)
    end

    it "sets price_cents from reais" do
      service.price_in_reais = 80.00
      expect(service.price_cents).to eq(8000)
    end

    it "formats price with currency symbol" do
      expect(service.formatted_price).to include("65,50")
    end
  end

  describe "multi-tenancy" do
    let(:tenant1) { create(:tenant) }
    let(:tenant2) { create(:tenant) }
    let!(:srv1) { create(:service, tenant: tenant1) }
    let!(:srv2) { create(:service, tenant: tenant2) }

    it "scopes services to current tenant" do
      ActsAsTenant.with_tenant(tenant1) do
        expect(Service.all).to include(srv1)
        expect(Service.all).not_to include(srv2)
      end
    end
  end

  describe "scopes" do
    let!(:active_srv) { create(:service, active: true) }
    let!(:inactive_srv) { create(:service, :inactive) }

    it "returns only active services with .active" do
      expect(Service.active).to include(active_srv)
      expect(Service.active).not_to include(inactive_srv)
    end
  end
end
