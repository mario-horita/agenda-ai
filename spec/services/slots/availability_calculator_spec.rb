require 'rails_helper'

RSpec.describe Slots::AvailabilityCalculator do
  let(:tenant) { create(:tenant, timezone: "America/Sao_Paulo") }
  let(:professional) { create(:professional, tenant: tenant, buffer_minutes: 10, active: true) }
  let(:service) { create(:service, tenant: tenant, duration_minutes: 30, active: true) }

  # Test date set to a specific next Monday in the future
  let(:target_date) { (Date.current + 7.days).beginning_of_week } # Next Monday (day_of_week = 1)

  before do
    # Configure availability for Monday: 09:00 to 12:00 (3 hours = 180 min)
    create(:availability,
           professional: professional,
           day_of_week: 1,
           start_time: Time.zone.parse("09:00"),
           end_time: Time.zone.parse("12:00"))
  end

  subject(:calculator) do
    described_class.new(
      professional: professional,
      service: service,
      date: target_date
    )
  end

  describe "#call" do
    context "when professional has regular availability and no conflicts" do
      it "generates slots sequentially respecting duration + buffer (30m + 10m = 40m step)" do
        # 09:00 - 09:30 (+10m buffer -> next 09:40)
        # 09:40 - 10:10 (+10m buffer -> next 10:20)
        # 10:20 - 10:50 (+10m buffer -> next 11:00)
        # 11:00 - 11:30 (+10m buffer -> next 11:40)
        # 11:40 - 12:10 (exceeds 12:00 window, so not included)
        slots = calculator.call

        expect(slots.size).to eq(4)
        expect(slots.map { |s| s[:formatted_time] }).to eq([ "09:00", "09:40", "10:20", "11:00" ])
        expect(slots.map { |s| s[:formatted_end_time] }).to eq([ "09:30", "10:10", "10:50", "11:30" ])
      end
    end

    context "when a partial time block exists" do
      before do
        # Block between 09:30 and 10:30
        create(:time_block,
               professional: professional,
               start_date: target_date,
               end_date: target_date,
               start_time: Time.zone.parse("09:30"),
               end_time: Time.zone.parse("10:30"),
               reason: "Reunião de Equipe",
               all_day: false)
      end

      it "excludes slots overlapping with the time block" do
        slots = calculator.call

        # 09:00-09:30 is available
        # 09:40-10:10 is in blocked interval -> excluded
        # 10:20-10:50 overlaps with 09:30-10:30 -> excluded
        # 11:00-11:30 is after block -> available
        expect(slots.map { |s| s[:formatted_time] }).to eq([ "09:00", "11:00" ])
      end
    end

    context "when an all-day time block exists" do
      before do
        create(:time_block,
               professional: professional,
               start_date: target_date,
               end_date: target_date,
               all_day: true,
               reason: "Férias")
      end

      it "returns an empty array" do
        expect(calculator.call).to be_empty
      end
    end

    context "when an active appointment exists" do
      let(:client) { create(:client, tenant: tenant) }

      before do
        # Existing appointment at 09:40 to 10:10
        appt_start = Time.use_zone("America/Sao_Paulo") { Time.zone.local(target_date.year, target_date.month, target_date.day, 9, 40) }
        create(:appointment,
               tenant: tenant,
               professional: professional,
               service: service,
               client: client,
               starts_at: appt_start,
               ends_at: appt_start + 30.minutes,
               status: "confirmed")
      end

      it "excludes the slot occupied by the appointment" do
        slots = calculator.call
        expect(slots.map { |s| s[:formatted_time] }).to eq([ "09:00", "10:20", "11:00" ])
      end
    end

    context "when a cancelled appointment exists at that slot" do
      let(:client) { create(:client, tenant: tenant) }

      before do
        appt_start = Time.use_zone("America/Sao_Paulo") { Time.zone.local(target_date.year, target_date.month, target_date.day, 9, 40) }
        create(:appointment,
               :cancelled,
               tenant: tenant,
               professional: professional,
               service: service,
               client: client,
               starts_at: appt_start,
               ends_at: appt_start + 30.minutes)
      end

      it "does not block the slot because cancelled appointments are ignored" do
        slots = calculator.call
        expect(slots.map { |s| s[:formatted_time] }).to include("09:40")
      end
    end

    context "when professional does not work on that day" do
      let(:sunday_date) { (Date.current + 7.days).beginning_of_week - 1.day } # Sunday (wday = 0)

      subject(:calculator) do
        described_class.new(
          professional: professional,
          service: service,
          date: sunday_date
        )
      end

      it "returns empty array" do
        expect(calculator.call).to be_empty
      end
    end

    context "when professional is inactive" do
      before { professional.update!(active: false) }

      it "returns empty array" do
        expect(calculator.call).to be_empty
      end
    end

    context "when service is inactive" do
      before { service.update!(active: false) }

      it "returns empty array" do
        expect(calculator.call).to be_empty
      end
    end
  end
end
