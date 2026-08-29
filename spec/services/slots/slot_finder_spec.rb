require 'rails_helper'

RSpec.describe Slots::SlotFinder do
  let(:tenant) { create(:tenant, timezone: "America/Sao_Paulo") }
  let(:service) { create(:service, tenant: tenant, duration_minutes: 30) }
  let(:prof1) { create(:professional, tenant: tenant, name: "Profissional 1", buffer_minutes: 0) }
  let(:prof2) { create(:professional, tenant: tenant, name: "Profissional 2", buffer_minutes: 0) }

  let(:target_date) { (Date.current + 7.days).beginning_of_week } # Monday

  before do
    prof1.services << service
    prof2.services << service

    # Prof 1: Mon 09:00 - 10:00 (2 slots: 09:00, 09:30)
    create(:availability, professional: prof1, day_of_week: 1, start_time: Time.zone.parse("09:00"), end_time: Time.zone.parse("10:00"))

    # Prof 2: Mon 14:00 - 15:00 (2 slots: 14:00, 14:30)
    create(:availability, professional: prof2, day_of_week: 1, start_time: Time.zone.parse("14:00"), end_time: Time.zone.parse("15:00"))
  end

  describe "#call" do
    context "when a specific professional is given" do
      it "returns available slots only for that professional" do
        finder = described_class.new(tenant: tenant, service: service, date: target_date, professional: prof1)
        results = finder.call

        expect(results.keys).to eq([ prof1 ])
        expect(results[prof1].size).to eq(2)
        expect(results[prof1].map { |s| s[:formatted_time] }).to eq([ "09:00", "09:30" ])
      end
    end

    context "when no professional is specified (search all)" do
      it "aggregates available slots across all professionals offering the service" do
        finder = described_class.new(tenant: tenant, service: service, date: target_date)
        results = finder.call

        expect(results.keys).to contain_exactly(prof1, prof2)
      end
    end
  end

  describe "#available_slots_combined" do
    it "returns all slots sorted chronologically with professional info" do
      finder = described_class.new(tenant: tenant, service: service, date: target_date)
      combined = finder.available_slots_combined

      expect(combined.size).to eq(4)
      expect(combined.map { |s| s[:formatted_time] }).to eq([ "09:00", "09:30", "14:00", "14:30" ])
      expect(combined.first[:professional_name]).to eq("Profissional 1")
      expect(combined.last[:professional_name]).to eq("Profissional 2")
    end
  end
end
