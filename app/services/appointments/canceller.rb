module Appointments
  class Canceller
    attr_reader :appointment, :reason, :cancelled_by, :errors

    def initialize(appointment:, reason: nil, cancelled_by: "client")
      @appointment = appointment
      @reason = reason
      @cancelled_by = cancelled_by
      @errors = []
    end

    def call
      tenant = appointment.tenant
      setting = tenant.tenant_setting

      # Validate cancellation policy if cancelled by client
      if cancelled_by == "client" && setting&.cancellation_window_hours.to_i.positive?
        hours_until_start = (appointment.starts_at - Time.current) / 1.hour
        if hours_until_start < setting.cancellation_window_hours
          @errors << "Cancelamentos permitidos apenas com antecedência mínima de #{setting.cancellation_window_hours} horas."
          return false
        end
      end

      appointment.update!(
        status: :cancelled,
        cancellation_reason: reason,
        cancelled_at: Time.current,
        cancelled_by: cancelled_by
      )

      Notifications::Dispatcher.new(appointment).dispatch(:cancellation)

      true
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      false
    end
  end
end
