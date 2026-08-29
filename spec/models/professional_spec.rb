require 'rails_helper'

RSpec.describe Professional, type: :model do
  describe "associations" do
    it { should belong_to(:tenant) }
    it { should have_many(:professional_services).dependent(:destroy) }
    it { should have_many(:services).through(:professional_services) }
    it { should have_many(:availabilities).dependent(:destroy) }
    it { should have_many(:time_blocks).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:professional) }

    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:buffer_minutes).is_greater_than_or_equal_to(0) }

    it "validates email format if present" do
      expect(build(:professional, email: "valid@email.com")).to be_valid
      expect(build(:professional, email: "")).to be_valid
      expect(build(:professional, email: "invalid-email")).not_to be_valid
    end
  end

  describe "callbacks" do
    it "generates a UUID on create" do
      professional = create(:professional)
      expect(professional.id).to be_present
      expect(professional.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "multi-tenancy" do
    let(:tenant1) { create(:tenant) }
    let(:tenant2) { create(:tenant) }
    let!(:prof1) { create(:professional, tenant: tenant1) }
    let!(:prof2) { create(:professional, tenant: tenant2) }

    it "scopes professionals to current tenant" do
      ActsAsTenant.with_tenant(tenant1) do
        expect(Professional.all).to include(prof1)
        expect(Professional.all).not_to include(prof2)
      end
    end
  end

  describe "scopes" do
    let!(:active_prof) { create(:professional, active: true) }
    let!(:inactive_prof) { create(:professional, :inactive) }

    it "returns only active professionals with .active" do
      expect(Professional.active).to include(active_prof)
      expect(Professional.active).not_to include(inactive_prof)
    end
  end
end
