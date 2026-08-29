require 'rails_helper'

RSpec.describe "Onboarding", type: :request do
  describe "GET /onboarding/new" do
    it "renders the onboarding sign up form" do
      get new_onboarding_path(plan: "pro")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Crie sua conta em 1 minuto")
      expect(response.body).to include("Starter")
      expect(response.body).to include("Pro")
      expect(response.body).to include("Enterprise")
    end
  end

  describe "POST /onboarding" do
    context "with valid parameters for Pro plan" do
      let(:params) do
        {
          tenant: {
            name: "Novo Salão Elegance",
            slug: "novo-salao-elegance",
            phone: "(11) 98888-7777",
            plan: "pro"
          },
          user: {
            name: "Administrador Elegance",
            email: "admin@elegance.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates the tenant, admin user and redirects to subscription page" do
        expect do
          post onboarding_index_path, params: params
        end.to change(Tenant, :count).by(1).and change(User, :count).by(1)

        tenant = Tenant.last
        expect(tenant.name).to eq("Novo Salão Elegance")
        expect(tenant.plan).to eq("pro")
        expect(tenant.trial_ends_at).to be_present

        expect(response).to redirect_to(admin_subscription_path(tenant_slug: tenant.slug))
      end
    end

    context "with valid parameters for Starter plan" do
      let(:params) do
        {
          tenant: {
            name: "Barbearia do Zé",
            slug: "barbearia-do-ze",
            phone: "(11) 97777-6666",
            plan: "starter"
          },
          user: {
            name: "Zé Barbeiro",
            email: "ze@barbearia.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates the tenant and redirects to admin dashboard" do
        expect do
          post onboarding_index_path, params: params
        end.to change(Tenant, :count).by(1).and change(User, :count).by(1)

        tenant = Tenant.last
        expect(response).to redirect_to(admin_root_path(tenant_slug: tenant.slug))
      end
    end
  end
end
