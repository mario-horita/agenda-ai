module Appointments
  class SlotUnavailableError < StandardError; end
  class CancellationPolicyError < StandardError; end
  class ReschedulePolicyError < StandardError; end

  class Creator
    attr_reader :tenant, :professional, :service, :client_params, :starts_at, :timezone, :errors, :appointment

    def initialize(tenant:, professional:, service:, client_params:, starts_at:)
      @tenant = tenant
      @professional = professional
      @service = service
      @client_params = client_params
      @timezone = tenant&.timezone || "America/Sao_Paulo"
      @starts_at = if starts_at.is_a?(String)
                     Time.use_zone(@timezone) { Time.zone.parse(starts_at) }
      else
                     starts_at.in_time_zone(@timezone)
      end
      @errors = []
    end

    def call
      ActiveRecord::Base.transaction do
        # 1. Resolve or create client
        client = find_or_create_client!

        # 2. Compute ends_at
        ends_at = starts_at + service.duration_minutes.minutes
        buffer = professional.buffer_minutes.to_i.minutes

        # 3. Prevent double-booking with atomic lock
        # Check active appointments overlapping [starts_at, ends_at + buffer]
        conflicting_appointment = Appointment.where(professional: professional)
                                             .where(status: [ :pending, :confirmed ])
                                             .where("starts_at < ? AND ends_at > ?", ends_at + buffer, starts_at)
                                             .lock("FOR UPDATE")
                                             .exists?

        if conflicting_appointment
          @errors << "O horário selecionado não está mais disponível. Por favor, escolha outro horário."
          raise SlotUnavailableError, @errors.first
        end

        # 4. Check time blocks
        local_date = starts_at.to_date
        time_blocks = professional.time_blocks.overlapping_period(local_date, local_date)

        Time.use_zone(timezone) do
          time_blocks.each do |tb|
            if tb.all_day?
              @errors << "O profissional está ausente nesta data (#{tb.reason})."
              raise SlotUnavailableError, @errors.first
            elsif tb.start_time.present? && tb.end_time.present?
              tb_start = Time.zone.local(local_date.year, local_date.month, local_date.day, tb.start_time.utc.hour, tb.start_time.utc.min)
              tb_end = Time.zone.local(local_date.year, local_date.month, local_date.day, tb.end_time.utc.hour, tb.end_time.utc.min)

              if starts_at < tb_end && ends_at > tb_start
                @errors << "O profissional possui um bloqueio de agenda neste horário (#{tb.reason})."
                raise SlotUnavailableError, @errors.first
              end
            end
          end
        end

        # 5. Create Appointment
        @appointment = Appointment.create!(
          tenant: tenant,
          professional: professional,
          service: service,
          client: client,
          starts_at: starts_at,
          ends_at: ends_at,
          price_cents: service.price_cents,
          status: :confirmed
        )

        client.update!(last_appointment_at: starts_at)

        # 6. Dispatch Notifications & Schedule Reminders
        Notifications::Dispatcher.new(@appointment).dispatch(:confirmation)
        Notifications::ReminderScheduler.new(@appointment).schedule

        @appointment
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      nil
    rescue SlotUnavailableError
      nil
    end

    private

    def find_or_create_client!
      email = client_params[:email]&.strip&.downcase
      phone = client_params[:phone]&.strip
      name = client_params[:name]&.strip

      client = if email.present?
                 tenant.clients.find_by(email: email)
      elsif phone.present?
                 tenant.clients.find_by(phone: phone)
      end

      if client
        client.update!(name: name) if name.present? && client.name.blank?
        client.update!(phone: phone) if phone.present? && client.phone.blank?
        client
      else
        tenant.clients.create!(
          name: name,
          email: email,
          phone: phone
        )
      end
    end
  end
end
