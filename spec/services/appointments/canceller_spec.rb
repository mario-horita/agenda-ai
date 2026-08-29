require 'rails_helper'

RSpec.describe Appointments::Canceller do
  let(:tenant) { create(:tenant) }
  let!(:setting) { tenant.tenant_setting.update!(cancellation_window_hours: 24) }
  let(:appointment) { create(:appointment, tenant: tenant, starts_at: Time.current + 48.hours) }

  describe "#call" do
    context "when cancellation is within allowed policy (>24h in advance)" do
      it "cancels the appointment successfully" do
        canceller = described_class.new(appointment: appointment, reason: "Imprevisto pessoal", cancelled_by: "client")
        expect(canceller.call).to be(true)

        expect(appointment.reload.status).to eq("cancelled")
        expect(appointment.cancellation_reason).to eq("Imprevisto pessoal")
        expect(appointment.cancelled_by).to eq("client")
        expect(appointment.cancelled_at).to be_present
      end
    end

    context "when client attempts to cancel inside the minimum window (<24h in advance)" do
      let(:late_appointment) { create(:appointment, tenant: tenant, starts_at: Time.current + 2.hours) }

      it "rejects cancellation and returns false with error" do
        canceller = described_class.new(appointment: late_appointment, reason: "Vou faltar", cancelled_by: "client")
        expect(canceller.call).to be(false)
        expect(canceller.errors.first).to include("Cancelamentos permitidos apenas com antecedência mínima de 24 horas.")
        expect(late_appointment.reload.status).to eq("confirmed")
      end
    end

    context "when admin cancels inside the window" do
      let(:late_appointment) { create(:appointment, tenant: tenant, starts_at: Time.current + 2.hours) }

      it "allows admin to cancel anytime" do
        canceller = described_class.new(appointment: late_appointment, reason: "Emergência do estabelecimento", cancelled_by: "admin")
        expect(canceller.call).to be(true)
        expect(late_appointment.reload.status).to eq("cancelled")
      end
    end
  end
end
