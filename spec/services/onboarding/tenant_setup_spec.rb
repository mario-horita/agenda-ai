require 'rails_helper'

RSpec.describe Onboarding::TenantSetup do
  describe "#call" do
    let(:tenant_params) do
      {
        name: "Clínica Vida",
        slug: "clinica-vida",
        phone: "(11) 91234-5678",
        plan: "pro"
      }
    end

    let(:user_params) do
      {
        name: "Dra. Ana",
        email: "ana@clinica.com",
        password: "securepassword123",
        password_confirmation: "securepassword123"
      }
    end

    subject(:service) { described_class.new(tenant_params: tenant_params, user_params: user_params) }

    context "with valid parameters" do
      it "creates a tenant, an admin user, and default settings" do
        result = service.call

        expect(result).to be_a(Hash)
        expect(result[:tenant]).to be_persisted
        expect(result[:tenant].name).to eq("Clínica Vida")
        expect(result[:tenant].slug).to eq("clinica-vida")
        expect(result[:tenant].tenant_setting).to be_present

        expect(result[:user]).to be_persisted
        expect(result[:user].email).to eq("ana@clinica.com")
        expect(result[:user].role).to eq("admin")
        expect(result[:user].tenant).to eq(result[:tenant])
      end
    end

    context "with invalid tenant parameters" do
      let(:tenant_params) { { name: "", slug: "invalid slug!" } }

      it "returns nil and populates errors" do
        result = service.call

        expect(result).to be_nil
        expect(service.errors).to be_present
        expect(Tenant.count).to eq(0)
        expect(User.count).to eq(0)
      end
    end

    context "with invalid user parameters" do
      let(:user_params) { { name: "", email: "invalid-email", password: "123" } }

      it "rolls back tenant creation and populates errors" do
        result = service.call

        expect(result).to be_nil
        expect(service.errors).to be_present
        expect(Tenant.count).to eq(0)
        expect(User.count).to eq(0)
      end
    end
  end
end
