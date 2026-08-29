module Admin
  class AvailabilitiesController < BaseController
    before_action :set_professional

    def index
      @availabilities = @professional.availabilities.ordered
      @availability = @professional.availabilities.build
    end

    def create
      @availability = @professional.availabilities.build(availability_params)
      if @availability.save
        redirect_to admin_professional_availabilities_path(tenant_slug: current_tenant.slug, professional_id: @professional.id),
                    notice: "Disponibilidade adicionada com sucesso."
      else
        @availabilities = @professional.availabilities.ordered
        render :index, status: :unprocessable_content
      end
    end

    def destroy
      @availability = @professional.availabilities.find(params[:id])
      @availability.destroy
      redirect_to admin_professional_availabilities_path(tenant_slug: current_tenant.slug, professional_id: @professional.id),
                  notice: "Horário de disponibilidade removido com sucesso."
    end

    private

    def set_professional
      @professional = current_tenant.professionals.find(params[:professional_id])
    end

    def availability_params
      params.require(:availability).permit(:day_of_week, :start_time, :end_time)
    end
  end
end
