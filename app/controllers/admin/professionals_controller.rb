module Admin
  class ProfessionalsController < BaseController
    before_action :set_professional, only: [ :show, :edit, :update, :destroy ]

    def index
      @professionals = current_tenant.professionals.order(:name)
    end

    def show
      @availabilities = @professional.availabilities.ordered
      @time_blocks = @professional.time_blocks.ordered
      @services = current_tenant.services.active.ordered
    end

    def new
      @professional = current_tenant.professionals.build(buffer_minutes: 0, active: true)
      @services = current_tenant.services.active.ordered
    end

    def create
      @professional = current_tenant.professionals.build(professional_params)
      if @professional.save
        update_service_associations if params[:professional][:service_ids]
        redirect_to admin_professional_path(tenant_slug: current_tenant.slug, id: @professional.id),
                    notice: "Profissional cadastrado com sucesso."
      else
        @services = current_tenant.services.active.ordered
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @services = current_tenant.services.active.ordered
    end

    def update
      if @professional.update(professional_params)
        update_service_associations if params[:professional][:service_ids]
        redirect_to admin_professional_path(tenant_slug: current_tenant.slug, id: @professional.id),
                    notice: "Profissional atualizado com sucesso."
      else
        @services = current_tenant.services.active.ordered
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @professional.destroy
      redirect_to admin_professionals_path(tenant_slug: current_tenant.slug),
                  notice: "Profissional removido com sucesso."
    end

    private

    def set_professional
      @professional = current_tenant.professionals.find(params[:id])
    end

    def professional_params
      params.require(:professional).permit(:name, :email, :phone, :bio, :avatar_url, :buffer_minutes, :active)
    end

    def update_service_associations
      service_ids = params[:professional][:service_ids].reject(&:blank?)
      @professional.service_ids = service_ids
    end
  end
end
