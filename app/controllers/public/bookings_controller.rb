module Public
  class BookingsController < ApplicationController
    layout "public"

    def index
      @tenant = current_tenant
      @services = current_tenant.services.active.ordered
      @selected_service = current_tenant.services.active.find_by(id: params[:service_id]) || @services.first
      @professionals = if @selected_service
                         @selected_service.professionals.active
      else
                         current_tenant.professionals.active
      end
      @selected_professional = @professionals.find_by(id: params[:professional_id])
      @date = begin
        Date.parse(params[:date])
      rescue StandardError
        Date.current
      end
    end

    def new
      @tenant = current_tenant
      @service = current_tenant.services.active.find(params[:service_id])
      @professional = current_tenant.professionals.active.find(params[:professional_id])
      @starts_at = Time.use_zone(@tenant.timezone) { Time.zone.parse(params[:starts_at]) }
      @client = Client.new
    end

    def create
      @tenant = current_tenant
      service = current_tenant.services.active.find(params[:service_id])
      professional = current_tenant.professionals.active.find(params[:professional_id])

      creator = Appointments::Creator.new(
        tenant: current_tenant,
        professional: professional,
        service: service,
        client_params: client_params,
        starts_at: params[:starts_at]
      )

      appointment = creator.call

      if appointment
        redirect_to public_booking_path(tenant_slug: current_tenant.slug, id: appointment.id),
                    notice: "Agendamento realizado com sucesso!"
      else
        redirect_to public_bookings_path(tenant_slug: current_tenant.slug, service_id: service.id, professional_id: professional.id),
                    alert: creator.errors.first || "Não foi possível confirmar o agendamento."
      end
    end

    def show
      @tenant = current_tenant
      @appointment = current_tenant.appointments.find(params[:id])
    end

    private

    def client_params
      params.require(:client).permit(:name, :email, :phone)
    end
  end
end
