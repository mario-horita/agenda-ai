module Admin
  class ServicesController < BaseController
    before_action :set_service, only: [ :show, :edit, :update, :destroy ]

    def index
      @services = current_tenant.services.ordered
    end

    def show
      @professionals = @service.professionals.active
    end

    def new
      @service = current_tenant.services.build(duration_minutes: 30, price_cents: 0, active: true)
      @professionals = current_tenant.professionals.active
    end

    def create
      @service = current_tenant.services.build(service_params)
      @service.price_in_reais = params[:service][:price_in_reais] if params[:service][:price_in_reais].present?

      if @service.save
        update_professional_associations if params[:service][:professional_ids]
        redirect_to admin_services_path(tenant_slug: current_tenant.slug),
                    notice: "Serviço cadastrado com sucesso."
      else
        @professionals = current_tenant.professionals.active
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @professionals = current_tenant.professionals.active
    end

    def update
      @service.assign_attributes(service_params)
      @service.price_in_reais = params[:service][:price_in_reais] if params[:service][:price_in_reais].present?

      if @service.save
        update_professional_associations if params[:service][:professional_ids]
        redirect_to admin_services_path(tenant_slug: current_tenant.slug),
                    notice: "Serviço atualizado com sucesso."
      else
        @professionals = current_tenant.professionals.active
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @service.destroy
      redirect_to admin_services_path(tenant_slug: current_tenant.slug),
                  notice: "Serviço removido com sucesso."
    end

    private

    def set_service
      @service = current_tenant.services.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :description, :duration_minutes, :active, :sort_order)
    end

    def update_professional_associations
      prof_ids = params[:service][:professional_ids].reject(&:blank?)
      @service.professional_ids = prof_ids
    end
  end
end
