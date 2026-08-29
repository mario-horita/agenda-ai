require 'rails_helper'

RSpec.describe "Admin::Professionals", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let!(:professional) { create(:professional, tenant: tenant, name: "Lucas Barbeiro") }
  let!(:service) { create(:service, tenant: tenant, name: "Corte") }

  before { login_as(user, scope: :user) }

  describe "GET /:tenant_slug/admin/professionals" do
    it "renders the index list of professionals" do
      get admin_professionals_path(tenant_slug: tenant.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Lucas Barbeiro")
    end
  end

  describe "GET /:tenant_slug/admin/professionals/:id" do
    it "renders the show view of the professional" do
      get admin_professional_path(tenant_slug: tenant.slug, id: professional.id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Lucas Barbeiro")
    end
  end

  describe "GET /:tenant_slug/admin/professionals/new" do
    it "renders the new professional form" do
      get new_admin_professional_path(tenant_slug: tenant.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cadastrar Profissional")
    end
  end

  describe "POST /:tenant_slug/admin/professionals" do
    context "with valid attributes" do
      it "creates a new professional and redirects to show" do
        expect do
          post admin_professionals_path(tenant_slug: tenant.slug), params: {
            professional: {
              name: "Novo Profissional",
              email: "novo@empresa.com",
              phone: "(11) 99999-8888",
              buffer_minutes: 15,
              active: true,
              service_ids: [ service.id ]
            }
          }
        end.to change(Professional, :count).by(1)

        new_prof = Professional.last
        expect(new_prof.services).to include(service)
        expect(response).to redirect_to(admin_professional_path(tenant_slug: tenant.slug, id: new_prof.id))
      end
    end

    context "with invalid attributes" do
      it "does not create and renders new with 422" do
        expect do
          post admin_professionals_path(tenant_slug: tenant.slug), params: {
            professional: { name: "" }
          }
        end.not_to change(Professional, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /:tenant_slug/admin/professionals/:id" do
    it "updates the professional successfully" do
      patch admin_professional_path(tenant_slug: tenant.slug, id: professional.id), params: {
        professional: { name: "Lucas Atualizado" }
      }
      expect(response).to redirect_to(admin_professional_path(tenant_slug: tenant.slug, id: professional.id))
      expect(professional.reload.name).to eq("Lucas Atualizado")
    end
  end

  describe "DELETE /:tenant_slug/admin/professionals/:id" do
    it "destroys the professional and redirects to index" do
      expect do
        delete admin_professional_path(tenant_slug: tenant.slug, id: professional.id)
      end.to change(Professional, :count).by(-1)

      expect(response).to redirect_to(admin_professionals_path(tenant_slug: tenant.slug))
    end
  end
end
