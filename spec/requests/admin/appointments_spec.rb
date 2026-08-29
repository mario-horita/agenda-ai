require 'rails_helper'

RSpec.describe "Admin::Appointments", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let!(:appointment) { create(:appointment, tenant: tenant, status: "confirmed") }

  before { login_as(user, scope: :user) }

  describe "GET /:tenant_slug/admin/appointments" do
    it "renders the appointments list" do
      get admin_appointments_path(tenant_slug: tenant.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(CGI.escapeHTML(appointment.client.name))
      expect(response.body).to include(CGI.escapeHTML(appointment.service.name))
    end
  end

  describe "PATCH /:tenant_slug/admin/appointments/:id/complete" do
    it "marks the appointment as completed" do
      patch complete_admin_appointment_path(tenant_slug: tenant.slug, id: appointment.id)
      expect(response).to redirect_to(admin_appointments_path(tenant_slug: tenant.slug))
      expect(appointment.reload.status).to eq("completed")
    end
  end

  describe "PATCH /:tenant_slug/admin/appointments/:id/no_show" do
    it "marks the appointment as no_show and increments client counter" do
      patch no_show_admin_appointment_path(tenant_slug: tenant.slug, id: appointment.id)
      expect(response).to redirect_to(admin_appointments_path(tenant_slug: tenant.slug))
      expect(appointment.reload.status).to eq("no_show")
      expect(appointment.client.reload.no_show_count).to eq(1)
    end
  end

  describe "PATCH /:tenant_slug/admin/appointments/:id/cancel" do
    it "cancels the appointment" do
      patch cancel_admin_appointment_path(tenant_slug: tenant.slug, id: appointment.id), params: { reason: "Cliente solicitou via WhatsApp" }
      expect(response).to redirect_to(admin_appointments_path(tenant_slug: tenant.slug))
      expect(appointment.reload.status).to eq("cancelled")
    end
  end
end
