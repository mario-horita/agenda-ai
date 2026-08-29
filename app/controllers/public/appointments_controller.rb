module Public
  class AppointmentsController < ApplicationController
    layout "public"
    before_action :set_appointment

    def show
      @tenant = current_tenant
    end

    def cancel
      canceller = Appointments::Canceller.new(
        appointment: @appointment,
        reason: params[:reason],
        cancelled_by: "client"
      )

      if canceller.call
        redirect_to public_appointment_path(tenant_slug: current_tenant.slug, id: @appointment.id),
                    notice: "Agendamento cancelado com sucesso."
      else
        redirect_to public_appointment_path(tenant_slug: current_tenant.slug, id: @appointment.id),
                    alert: canceller.errors.first || "Não foi possível cancelar o agendamento."
      end
    end

    def reschedule
      @tenant = current_tenant
      @service = @appointment.service
      @professional = @appointment.professional
      @date = begin
        Date.parse(params[:date])
      rescue StandardError
        Date.current
      end
    end

    def update
      # Handled via patch :reschedule
    end

    private

    def set_appointment
      @appointment = current_tenant.appointments.find(params[:id])
    end
  end
end
