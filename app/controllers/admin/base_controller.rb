module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_user_belongs_to_tenant!

    layout "admin"

    private

    def ensure_user_belongs_to_tenant!
      return unless current_user && current_tenant

      if current_user.tenant_id != current_tenant.id
        sign_out current_user
        redirect_to new_user_session_path, alert: "Você não tem permissão para acessar esta empresa."
      end
    end
  end
end
