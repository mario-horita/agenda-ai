require 'rails_helper'

RSpec.describe "Public::Bookings", type: :request do
  let(:tenant) { create(:tenant, timezone: "America/Sao_Paulo") }
  let!(:service) { create(:service, tenant: tenant, name: "Corte Masculino", price_cents: 5000, duration_minutes: 30) }
  let!(:professional) { create(:professional, tenant: tenant, name: "Lucas Barbeiro") }
  let(:target_time) { (Time.current + 2.days).change(hour: 10, min: 0, sec: 0) }

  before do
    professional.services << service
  end

  describe "GET /:tenant_slug/public/bookings" do
    it "renders the multi-step booking page" do
      get public_bookings_path(tenant_slug: tenant.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Corte Masculino")
      expect(response.body).to include("Lucas Barbeiro")
    end
  end

  describe "GET /:tenant_slug/public/bookings/new" do
    it "renders the checkout contact form with summary" do
      get new_public_booking_path(tenant_slug: tenant.slug), params: {
        service_id: service.id,
        professional_id: professional.id,
        starts_at: target_time.iso8601
      }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Seus Dados de Contato")
      expect(response.body).to include("Corte Masculino")
      expect(response.body).to include("Lucas Barbeiro")
    end
  end

  describe "POST /:tenant_slug/public/bookings" do
    context "with valid parameters" do
      it "creates the appointment and redirects to the confirmation show view" do
        expect do
          post public_bookings_path(tenant_slug: tenant.slug), params: {
            service_id: service.id,
            professional_id: professional.id,
            starts_at: target_time.iso8601,
            client: {
              name: "Marcos Cliente",
              phone: "(11) 97777-1234",
              email: "marcos@cliente.com"
            }
          }
        end.to change(Appointment, :count).by(1)

        appointment = Appointment.last
        expect(response).to redirect_to(public_booking_path(tenant_slug: tenant.slug, id: appointment.id))
      end
    end
  end

  describe "GET /:tenant_slug/public/bookings/:id" do
    let(:appointment) { create(:appointment, tenant: tenant, service: service, professional: professional) }

    it "renders the confirmation card" do
      get public_booking_path(tenant_slug: tenant.slug, id: appointment.id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Agendamento Confirmado!")
      expect(response.body).to include(appointment.client.name)
    end
  end
end
