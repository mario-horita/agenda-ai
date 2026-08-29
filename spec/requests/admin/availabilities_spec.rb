require 'rails_helper'

RSpec.describe "Admin::Availabilities", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:professional) { create(:professional, tenant: tenant) }
  let!(:availability) { create(:availability, professional: professional, day_of_week: 1) }

  before { login_as(user, scope: :user) }

  describe "GET /:tenant_slug/admin/professionals/:professional_id/availabilities" do
    it "renders the availabilities index" do
      get admin_professional_availabilities_path(tenant_slug: tenant.slug, professional_id: professional.id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Disponibilidade Semanal")
      expect(response.body).to include(professional.name)
    end
  end

  describe "POST /:tenant_slug/admin/professionals/:professional_id/availabilities" do
    context "with valid parameters" do
      it "creates a new availability record" do
        expect do
          post admin_professional_availabilities_path(tenant_slug: tenant.slug, professional_id: professional.id), params: {
            availability: {
              day_of_week: 2,
              start_time: "09:00",
              end_time: "18:00"
            }
          }
        end.to change(Availability, :count).by(1)

        expect(response).to redirect_to(admin_professional_availabilities_path(tenant_slug: tenant.slug, professional_id: professional.id))
      end
    end

    context "with invalid parameters (end_time before start_time)" do
      it "does not create and renders index with 422" do
        expect do
          post admin_professional_availabilities_path(tenant_slug: tenant.slug, professional_id: professional.id), params: {
            availability: {
              day_of_week: 3,
              start_time: "18:00",
              end_time: "09:00"
            }
          }
        end.not_to change(Availability, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /:tenant_slug/admin/professionals/:professional_id/availabilities/:id" do
    it "deletes the availability record" do
      expect do
        delete admin_professional_availability_path(tenant_slug: tenant.slug, professional_id: professional.id, id: availability.id)
      end.to change(Availability, :count).by(-1)

      expect(response).to redirect_to(admin_professional_availabilities_path(tenant_slug: tenant.slug, professional_id: professional.id))
    end
  end
end
