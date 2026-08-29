module SetCurrentTenantConcern
  extend ActiveSupport::Concern

  included do
    set_current_tenant_through_filter
    before_action :set_tenant_from_slug
    helper_method :current_tenant
  end

  private

  def set_tenant_from_slug
    return unless params[:tenant_slug]

    tenant = Tenant.find_by(slug: params[:tenant_slug].downcase)
    if tenant
      set_current_tenant(tenant)
    else
      render plain: "Empresa não encontrada", status: :not_found
    end
  end
end
