require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should belong_to(:tenant) }
  end

  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:role) }

    it "validates role inclusion" do
      expect(build(:user, role: "admin")).to be_valid
      expect(build(:user, role: "manager")).to be_valid
      expect { build(:user, role: "guest") }.to raise_error(ArgumentError)
    end
  end

  describe "callbacks" do
    it "generates a UUID on create" do
      user = create(:user)
      expect(user.id).to be_present
      expect(user.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "multi-tenancy" do
    let(:tenant1) { create(:tenant) }
    let(:tenant2) { create(:tenant) }
    let!(:user1) { create(:user, tenant: tenant1) }
    let!(:user2) { create(:user, tenant: tenant2) }

    it "scopes users to current tenant with acts_as_tenant" do
      ActsAsTenant.with_tenant(tenant1) do
        expect(User.all).to include(user1)
        expect(User.all).not_to include(user2)
      end

      ActsAsTenant.with_tenant(tenant2) do
        expect(User.all).to include(user2)
        expect(User.all).not_to include(user1)
      end
    end
  end
end
