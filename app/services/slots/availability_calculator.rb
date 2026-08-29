module Slots
  class AvailabilityCalculator
    attr_reader :professional, :service, :date, :timezone, :step_minutes

    def initialize(professional:, service:, date:, step_minutes: nil)
      @professional = professional
      @service = service
      @date = date.is_a?(String) ? Date.parse(date) : date
      @timezone = professional.tenant&.timezone || "America/Sao_Paulo"
      @step_minutes = step_minutes
    end

    def call
      return [] unless professional.active? && service.active?

      Time.use_zone(timezone) do
        availabilities = professional.availabilities.for_day(date.wday)
        return [] if availabilities.empty?

        time_blocks = professional.time_blocks.overlapping_period(date, date)
        return [] if time_blocks.any?(&:all_day?)

        existing_appointments = professional.appointments.active.where(
          "starts_at < ? AND ends_at > ?",
          date.end_of_day,
          date.beginning_of_day
        )

        generate_available_slots(availabilities, time_blocks, existing_appointments)
      end
    end

    private

    def generate_available_slots(availabilities, time_blocks, existing_appointments)
      duration = service.duration_minutes.minutes
      buffer = professional.buffer_minutes.to_i.minutes
      step = step_minutes ? step_minutes.minutes : (duration + buffer)

      slots = []

      availabilities.each do |avail|
        window_start = Time.zone.local(date.year, date.month, date.day, avail.start_time.utc.hour, avail.start_time.utc.min)
        window_end = Time.zone.local(date.year, date.month, date.day, avail.end_time.utc.hour, avail.end_time.utc.min)

        current_start = window_start

        while current_start + duration <= window_end
          current_end = current_start + duration

          if slot_available?(current_start, current_end, time_blocks, existing_appointments, buffer)
            slots << {
              starts_at: current_start,
              ends_at: current_end,
              formatted_time: current_start.strftime("%H:%M"),
              formatted_end_time: current_end.strftime("%H:%M")
            }
          end

          current_start += (step.positive? ? step : 30.minutes)
        end
      end

      slots
    end

    def slot_available?(slot_start, slot_end, time_blocks, existing_appointments, buffer)
      # 1. Slot cannot be in the past
      return false if slot_start <= Time.current

      # 2. Check time blocks
      time_blocks.each do |tb|
        if tb.all_day?
          return false
        elsif tb.start_time.present? && tb.end_time.present?
          block_start = Time.zone.local(date.year, date.month, date.day, tb.start_time.utc.hour, tb.start_time.utc.min)
          block_end = Time.zone.local(date.year, date.month, date.day, tb.end_time.utc.hour, tb.end_time.utc.min)

          return false if slot_start < block_end && slot_end > block_start
        end
      end

      # 3. Check existing appointments (including buffer)
      existing_appointments.each do |appt|
        appt_start = appt.starts_at
        appt_end_with_buffer = appt.ends_at + buffer

        return false if slot_start < appt_end_with_buffer && slot_end > appt_start
      end

      true
    end
  end
end
