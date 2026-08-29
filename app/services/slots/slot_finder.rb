module Slots
  class SlotFinder
    attr_reader :tenant, :service, :professional, :date

    def initialize(tenant:, service:, date:, professional: nil)
      @tenant = tenant
      @service = service
      @date = date.is_a?(String) ? Date.parse(date) : date
      @professional = professional
    end

    def call
      professionals_to_check = if professional
                                 [ professional ]
      else
                                 service.professionals.active
      end

      results = {}

      professionals_to_check.each do |prof|
        calculator = Slots::AvailabilityCalculator.new(
          professional: prof,
          service: service,
          date: date
        )
        slots = calculator.call
        results[prof] = slots if slots.any?
      end

      results
    end

    # Returns all slots flattened and deduplicated/sorted chronologically
    def available_slots_combined
      all_slots = []

      call.each do |prof, slots|
        slots.each do |slot|
          all_slots << slot.merge(professional_id: prof.id, professional_name: prof.name)
        end
      end

      all_slots.sort_by { |s| s[:starts_at] }
    end
  end
end
