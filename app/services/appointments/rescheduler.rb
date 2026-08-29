module Appointments
  class Rescheduler
    attr_reader :appointment, :new_starts_at, :new_professional, :errors

    def initialize(appointment:, new_starts_at:, new_professional: nil)
      @appointment = appointment
      @new_starts_at = new_starts_at.is_a?(String) ? Time.zone.parse(new_starts_at) : new_starts_at
      @new_professional = new_professional || appointment.professional
      @errors = []
    end

    def call
      tenant = appointment.tenant
      setting = tenant.tenant_setting

      if setting && !setting.allow_reschedule?
        @errors << "Reagendamentos não são permitidos por este estabelecimento."
        return false
      end

      service = appointment.service
      new_ends_at = new_starts_at + service.duration_minutes.minutes
      buffer = new_professional.buffer_minutes.to_i.minutes

      ActiveRecord::Base.transaction do
        # Check conflict on new slot
        conflict = Appointment.where(professional: new_professional)
                              .where(status: [ :pending, :confirmed ])
                              .where.not(id: appointment.id)
                              .where("starts_at < ? AND ends_at > ?", new_ends_at + buffer, new_starts_at)
                              .lock("FOR UPDATE")
                              .exists?

        if conflict
          @errors << "O novo horário selecionado não está mais disponível."
          return false
        end

        appointment.update!(
          professional: new_professional,
          starts_at: new_starts_at,
          ends_at: new_ends_at,
          status: :confirmed
        )

        true
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      false
    end
  end
end
