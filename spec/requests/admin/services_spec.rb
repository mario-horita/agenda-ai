require 'rails_helper'

RSpec.describe "Admin::Services", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let!(:service) { create(:service, tenant: tenant, name: "Barba Terapia", price_cents: 4500) }
  let!(:professional) { create(:professional, tenant: tenant, name: "Mariana") }

  before { login_as(user, scope: :user) }

  describe "GET /:tenant_slug/admin/services" do
    it "renders the services list" do
      get admin_services_path(tenant_slug: tenant.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Barba Terapia")
    end
  end

  describe "GET /:tenant_slug/admin/services/new" do
    it "renders the new service form" do
      get new_admin_service_path(tenant_slug: tenant.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cadastrar Serviço")
    end
  end

  describe "POST /:tenant_slug/admin/services" do
    context "with valid attributes" do
      it "creates a new service and redirects to index" do
        expect do
          post admin_services_path(tenant_slug: tenant.slug), params: {
            service: {
              name: "Corte Degradê",
              duration_minutes: 40,
              price_in_reais: "55.00",
              professional_ids: [ professional.id ]
            }
          }
        end.to change(Service, :count).by(1)

        new_srv = Service.last
        expect(new_srv.price_cents).to eq(5500)
        expect(new_srv.professionals).to include(professional)
        expect(response).to redirect_to(admin_services_path(tenant_slug: tenant.slug))
      end
    end

    context "with invalid attributes" do
      it "does not create and renders new with 422" do
        expect do
          post admin_services_path(tenant_slug: tenant.slug), params: {
            service: { name: "", duration_minutes: 0 }
          }
        end.not_to change(Service, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /:tenant_slug/admin/services/:id" do
    it "updates the service successfully" do
      patch admin_service_path(tenant_slug: tenant.slug, id: service.id), params: {
        service: { name: "Barba Terapia Especial", price_in_reais: "60.00" }
      }
      expect(response).to redirect_to(admin_services_path(tenant_slug: tenant.slug))
      expect(service.reload.name).to eq("Barba Terapia Especial")
      expect(service.price_cents).to eq(6000)
    end
  end

  describe "DELETE /:tenant_slug/admin/services/:id" do
    it "destroys the service and redirects to index" do
      expect do
        delete admin_service_path(tenant_slug: tenant.slug, id: service.id)
      end.to change(Service, :count).by(-1)

      expect(response).to redirect_to(admin_services_path(tenant_slug: tenant.slug))
    end
  end
end
