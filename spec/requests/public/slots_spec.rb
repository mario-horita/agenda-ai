require 'rails_helper'

RSpec.describe "Public::Slots", type: :request do
  let(:tenant) { create(:tenant, timezone: "America/Sao_Paulo") }
  let(:service) { create(:service, tenant: tenant, duration_minutes: 30) }
  let(:professional) { create(:professional, tenant: tenant, buffer_minutes: 0) }
  let(:target_date) { (Date.current + 7.days).beginning_of_week } # Monday

  before do
    professional.services << service
    create(:availability, professional: professional, day_of_week: 1, start_time: Time.zone.parse("09:00"), end_time: Time.zone.parse("11:00"))
  end

  describe "GET /:tenant_slug/public/slots" do
    context "with valid parameters requesting JSON" do
      it "returns 200 with JSON payload containing slots" do
        get public_slots_path(tenant_slug: tenant.slug),
            params: { service_id: service.id, professional_id: professional.id, date: target_date.to_s },
            headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["date"]).to eq(target_date.to_s)
        expect(json["slots_count"]).to eq(4) # 09:00, 09:30, 10:00, 10:30
        expect(json["slots"].first["formatted_time"]).to eq("09:00")
      end
    end

    context "with valid parameters requesting HTML partial" do
      it "returns 200 with rendered HTML partial" do
        get public_slots_path(tenant_slug: tenant.slug),
            params: { service_id: service.id, professional_id: professional.id, date: target_date.to_s }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("09:00")
        expect(response.body).to include("4 disponíveis")
      end
    end

    context "when service is not found" do
      it "returns 404 not found" do
        get public_slots_path(tenant_slug: tenant.slug),
            params: { service_id: "non-existent-uuid" },
            headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when date format is invalid" do
      it "returns 422 unprocessable entity" do
        get public_slots_path(tenant_slug: tenant.slug),
            params: { service_id: service.id, date: "invalid-date-string" },
            headers: { "ACCEPT" => "application/json" }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
