module Admin
  class AppointmentsController < BaseController
    before_action :set_appointment, only: [ :show, :cancel, :complete, :no_show ]

    def index
      @appointments = current_tenant.appointments.includes(:client, :professional, :service).chronological

      if params[:status].present? && params[:status] != "all"
        @appointments = @appointments.where(status: params[:status])
      end

      if params[:date].present?
        date = Date.parse(params[:date])
        @appointments = @appointments.for_date(date)
      end
    end

    def show
    end

    def cancel
      canceller = Appointments::Canceller.new(
        appointment: @appointment,
        reason: params[:reason] || "Cancelado pelo administrador",
        cancelled_by: "admin"
      )

      if canceller.call
        redirect_to admin_appointments_path(tenant_slug: current_tenant.slug),
                    notice: "Agendamento cancelado com sucesso."
      else
        redirect_to admin_appointments_path(tenant_slug: current_tenant.slug),
                    alert: canceller.errors.first || "Erro ao cancelar."
      end
    end

    def complete
      @appointment.update!(status: :completed)
      redirect_to admin_appointments_path(tenant_slug: current_tenant.slug),
                  notice: "Agendamento marcado como concluído."
    end

    def no_show
      @appointment.update!(status: :no_show)
      @appointment.client.increment!(:no_show_count)
      redirect_to admin_appointments_path(tenant_slug: current_tenant.slug),
                  notice: "Agendamento marcado como não compareceu (No-Show)."
    end

    private

    def set_appointment
      @appointment = current_tenant.appointments.find(params[:id])
    end
  end
end
