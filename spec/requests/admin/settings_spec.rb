require 'rails_helper'

RSpec.describe "Admin::Settings", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  before { login_as(user, scope: :user) }

  describe "GET /:tenant_slug/admin/setting/edit" do
    it "renders the settings edit form" do
      get edit_admin_setting_path(tenant_slug: tenant.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Configurações &amp; Políticas").or include("Configurações & Políticas")
      expect(response.body).to include("Janela Mínima de Cancelamento")
    end
  end

  describe "PATCH /:tenant_slug/admin/setting" do
    it "updates tenant and setting configurations" do
      patch admin_setting_path(tenant_slug: tenant.slug), params: {
        tenant: {
          name: "Novo Nome Salão",
          phone: "(11) 99999-0000"
        },
        tenant_setting: {
          cancellation_window_hours: 12,
          reminder_hours: 4,
          allow_reschedule: "1",
          notification_channels: [ "email", "whatsapp" ]
        }
      }

      expect(response).to redirect_to(edit_admin_setting_path(tenant_slug: tenant.slug))
      expect(tenant.reload.name).to eq("Novo Nome Salão")
      expect(tenant.tenant_setting.reload.cancellation_window_hours).to eq(12)
      expect(tenant.tenant_setting.notification_channels_array).to contain_exactly("email", "whatsapp")
    end
  end
end
