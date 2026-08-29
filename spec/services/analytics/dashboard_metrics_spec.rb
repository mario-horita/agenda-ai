require 'rails_helper'

RSpec.describe Analytics::DashboardMetrics do
  let(:tenant) { create(:tenant, timezone: "America/Sao_Paulo") }
  let(:professional) { create(:professional, tenant: tenant) }
  let(:service) { create(:service, tenant: tenant, price_cents: 5000) }

  before do
    # 2 completed appointments this month
    create(:appointment,
           :completed,
           tenant: tenant,
           professional: professional,
           service: service,
           price_cents: 5000,
           starts_at: Time.current.beginning_of_month + 2.days)

    create(:appointment,
           :completed,
           tenant: tenant,
           professional: professional,
           service: service,
           price_cents: 5000,
           starts_at: Time.current.beginning_of_month + 3.days)

    # 1 cancelled appointment
    create(:appointment,
           :cancelled,
           tenant: tenant,
           professional: professional,
           service: service,
           starts_at: Time.current.beginning_of_month + 4.days)

    # 1 no_show appointment
    create(:appointment,
           :no_show,
           tenant: tenant,
           professional: professional,
           service: service,
           starts_at: Time.current.beginning_of_month + 5.days)
  end

  subject(:metrics) { described_class.new(tenant: tenant, period: "this_month").call }

  describe "#call" do
    it "computes accurate metrics" do
      expect(metrics[:total_appointments]).to eq(4)
      expect(metrics[:completed_count]).to eq(2)
      expect(metrics[:cancelled_count]).to eq(1)
      expect(metrics[:no_show_count]).to eq(1)

      expect(metrics[:total_revenue_reais]).to eq(100.0) # 2 * 50.00
      expect(metrics[:no_show_rate]).to eq(25.0) # 1 / 4
      expect(metrics[:cancellation_rate]).to eq(25.0) # 1 / 4
    end

    it "aggregates top services and top professionals" do
      expect(metrics[:top_services].first[:name]).to eq(service.name)
      expect(metrics[:top_services].first[:count]).to eq(2)
      expect(metrics[:top_professionals].first[:name]).to eq(professional.name)
    end
  end
end
