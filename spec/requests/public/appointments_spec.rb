require 'rails_helper'

RSpec.describe "Public::Appointments", type: :request do
  let(:tenant) { create(:tenant) }
  let!(:setting) { tenant.tenant_setting.update!(cancellation_window_hours: 24) }
  let(:appointment) { create(:appointment, tenant: tenant, starts_at: Time.current + 48.hours) }

  describe "GET /:tenant_slug/public/appointments/:id" do
    it "renders the appointment details page" do
      get public_appointment_path(tenant_slug: tenant.slug, id: appointment.id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(appointment.service.name)
      expect(response.body).to include(appointment.professional.name)
    end
  end

  describe "PATCH /:tenant_slug/public/appointments/:id/cancel" do
    it "cancels the appointment and redirects with notice" do
      patch cancel_public_appointment_path(tenant_slug: tenant.slug, id: appointment.id), params: {
        reason: "Não poderei comparecer"
      }
      expect(response).to redirect_to(public_appointment_path(tenant_slug: tenant.slug, id: appointment.id))
      expect(appointment.reload.status).to eq("cancelled")
    end
  end
end
