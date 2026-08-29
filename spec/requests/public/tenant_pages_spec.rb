require 'rails_helper'

RSpec.describe "Public::TenantPages", type: :request do
  let(:tenant) { create(:tenant, name: "Studio Vip", slug: "studio-vip") }

  describe "GET /:tenant_slug/public/tenant_page" do
    context "when tenant exists" do
      it "returns a 200 ok and renders the public landing page" do
        get public_tenant_page_path(tenant_slug: tenant.slug)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Studio Vip")
        expect(response.body).to include("Agende seu horário online")
      end
    end

    context "when tenant does not exist" do
      it "returns a 404 not found" do
        get "/empresa-inexistente-xyz/public/tenant_page"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
