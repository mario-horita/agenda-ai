require 'rails_helper'

RSpec.describe "Admin::Dashboard", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  before { login_as(user, scope: :user) }

  describe "GET /:tenant_slug/admin" do
    it "renders the dashboard successfully with KPIs and metric charts" do
      get admin_root_path(tenant_slug: tenant.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Dashboard &amp; Métricas").or include("Dashboard & Métricas")
      expect(response.body).to include("Receita Prevista")
      expect(response.body).to include("Taxa de Faltas (No-Show)")
    end

    it "supports period filter params" do
      get admin_root_path(tenant_slug: tenant.slug, period: "today")
      expect(response).to have_http_status(:ok)
    end
  end
end
