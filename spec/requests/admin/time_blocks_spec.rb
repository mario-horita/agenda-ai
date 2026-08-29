require 'rails_helper'

RSpec.describe "Admin::TimeBlocks", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:professional) { create(:professional, tenant: tenant) }
  let!(:time_block) { create(:time_block, professional: professional, reason: "Férias") }

  before { login_as(user, scope: :user) }

  describe "GET /:tenant_slug/admin/professionals/:professional_id/time_blocks" do
    it "renders the time blocks index" do
      get admin_professional_time_blocks_path(tenant_slug: tenant.slug, professional_id: professional.id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Bloqueios de Horário")
      expect(response.body).to include("Férias")
    end
  end

  describe "POST /:tenant_slug/admin/professionals/:professional_id/time_blocks" do
    context "with valid parameters" do
      it "creates a new time block" do
        expect do
          post admin_professional_time_blocks_path(tenant_slug: tenant.slug, professional_id: professional.id), params: {
            time_block: {
              reason: "Dentista",
              start_date: Date.current + 2.days,
              end_date: Date.current + 2.days,
              start_time: "14:00",
              end_time: "16:00",
              all_day: false
            }
          }
        end.to change(TimeBlock, :count).by(1)

        expect(response).to redirect_to(admin_professional_time_blocks_path(tenant_slug: tenant.slug, professional_id: professional.id))
      end
    end

    context "with invalid parameters" do
      it "does not create and renders index with 422" do
        expect do
          post admin_professional_time_blocks_path(tenant_slug: tenant.slug, professional_id: professional.id), params: {
            time_block: {
              reason: "",
              start_date: Date.current + 5.days,
              end_date: Date.current
            }
          }
        end.not_to change(TimeBlock, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /:tenant_slug/admin/professionals/:professional_id/time_blocks/:id" do
    it "deletes the time block" do
      expect do
        delete admin_professional_time_block_path(tenant_slug: tenant.slug, professional_id: professional.id, id: time_block.id)
      end.to change(TimeBlock, :count).by(-1)

      expect(response).to redirect_to(admin_professional_time_blocks_path(tenant_slug: tenant.slug, professional_id: professional.id))
    end
  end
end
