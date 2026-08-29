require 'rails_helper'

RSpec.describe Client, type: :model do
  describe "associations" do
    it { should belong_to(:tenant) }
    it { should have_many(:appointments).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:client) }

    it { should validate_presence_of(:name) }

    it "validates email format if present" do
      expect(build(:client, email: "valid@email.com")).to be_valid
      expect(build(:client, email: "")).to be_valid
      expect(build(:client, email: "invalid-email")).not_to be_valid
    end
  end

  describe "callbacks" do
    it "generates a UUID on create" do
      client = create(:client)
      expect(client.id).to be_present
      expect(client.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "multi-tenancy" do
    let(:tenant1) { create(:tenant) }
    let(:tenant2) { create(:tenant) }
    let!(:client1) { create(:client, tenant: tenant1) }
    let!(:client2) { create(:client, tenant: tenant2) }

    it "scopes clients to current tenant" do
      ActsAsTenant.with_tenant(tenant1) do
        expect(Client.all).to include(client1)
        expect(Client.all).not_to include(client2)
      end
    end
  end
end
